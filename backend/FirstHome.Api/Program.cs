using System.Text;
using System.Text.Json.Serialization;
using FirstHome.Api.Data;
using FirstHome.Api.Infrastructure;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);
var cfg = builder.Configuration;

var port = Environment.GetEnvironmentVariable("PORT");
if (!string.IsNullOrEmpty(port))
{
    builder.WebHost.UseUrls($"http://+:{port}");
}

// ---- JWT (key comes from config/env; otherwise generated into git-ignored App_Data) ----
var jwtOpts = cfg.GetSection("Jwt").Get<JwtOptions>() ?? new JwtOptions();
jwtOpts.Key = LocalSecrets.GetOrCreate(cfg, "Jwt:Key", "jwt.key", () => LocalSecrets.RandomToken());
builder.Services.AddSingleton(jwtOpts);
builder.Services.AddSingleton<JwtService>();

// ---- Database ----
if (!builder.Environment.IsEnvironment("Testing"))
    builder.Services.AddDbContext<AppDbContext>(o =>
        o.UseSqlServer(cfg.GetConnectionString("Default")));

builder.Services.AddControllers()
    .AddJsonOptions(o => o.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()))
    .ConfigureApiBehaviorOptions(o => o.InvalidModelStateResponseFactory = Mapping.ValidationResponse);

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o =>
    {
        o.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true, ValidIssuer = jwtOpts.Issuer,
            ValidateAudience = true, ValidAudience = jwtOpts.Audience,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtOpts.Key)),
            ValidateLifetime = true, ClockSkew = TimeSpan.FromSeconds(30),
            RoleClaimType = System.Security.Claims.ClaimTypes.Role,
        };
        o.Events = new JwtBearerEvents
        {
            OnChallenge = async ctx =>
            {
                ctx.HandleResponse();
                await ErrorHandlingMiddleware.Write(ctx.HttpContext, new ApiError(401, "unauthorized",
                    "Authentication is required.", null, ctx.HttpContext.TraceIdentifier));
            },
            OnForbidden = async ctx => await ErrorHandlingMiddleware.Write(ctx.HttpContext, new ApiError(403,
                "forbidden", "You do not have permission to perform this action.", null,
                ctx.HttpContext.TraceIdentifier)),
        };
    });
builder.Services.AddAuthorization();

var origins = cfg.GetSection("Cors:Origins").Get<string[]>() ?? [];
builder.Services.AddCors(o => o.AddDefaultPolicy(p =>
{
    // Local dev: Flutter web serves from a random localhost port, so allow any localhost origin plus configured list and Vercel deployments.
    p.SetIsOriginAllowed(origin =>
    {
        try
        {
            var uri = new Uri(origin);
            return uri.IsLoopback ||
                   origins.Contains("*") ||
                   origins.Contains(origin) ||
                   origins.Any(o => origin.Equals(o, StringComparison.OrdinalIgnoreCase)) ||
                   uri.Host.EndsWith(".vercel.app", StringComparison.OrdinalIgnoreCase);
        }
        catch
        {
            return false;
        }
    })
    .AllowAnyHeader().AllowAnyMethod();
}));

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "FirstHome Nigeria API", Version = "v1",
        Description = "Concept Prototype - Subject to Final Scope & Agreement. Synthetic data only.",
    });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http, Scheme = "bearer", BearerFormat = "JWT", In = ParameterLocation.Header,
        Description = "Paste the token returned by /api/auth/login.",
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        [new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } }] = []
    });
});

var app = builder.Build();

app.UseMiddleware<ErrorHandlingMiddleware>();
app.UseCors();
app.UseSwagger();
app.UseSwaggerUI();
app.UseAuthentication();
app.UseAuthorization();
app.MapGet("/api/health", () => Results.Ok(new { status = "ok", time = DateTime.UtcNow })).AllowAnonymous();
app.MapGet("/", () => Results.Redirect("/swagger")).ExcludeFromDescription();
app.MapControllers();

if (!app.Environment.IsEnvironment("Testing"))
{
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    var log = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    try
    {
        log.LogInformation("Applying database migrations...");
        await db.Database.MigrateAsync();
        log.LogInformation("Database migrations applied successfully.");

        var adminPw = LocalSecrets.GetOrCreate(cfg, "Seed:AdminPassword", "seed-admin-password.txt", () => "Fh4212091d1df34b1051A1");
        var demoPw = LocalSecrets.GetOrCreate(cfg, "Seed:DemoPassword", "seed-demo-password.txt", () => "Fh9ae89105ef00edd81bA1");
        await Seeder.SeedAsync(db, adminPw, demoPw);
        log.LogInformation("Database seeded successfully.");
    }
    catch (Exception ex)
    {
        log.LogError(ex, "Database migration or seeding failed on startup. The API will start, but database endpoints will be unavailable until a reachable 'ConnectionStrings__Default' is configured.");
    }
}

app.Run();

public partial class Program { }
