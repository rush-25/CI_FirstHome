using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using FirstHome.Api.Domain;
using FirstHome.Api.Dtos;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;

namespace FirstHome.Api.Infrastructure;

/// <summary>
/// Resolves secrets from configuration/environment first. When absent (local dev), a random value is generated
/// once and stored in the git-ignored App_Data folder. Nothing secret is ever committed.
/// </summary>
public static class LocalSecrets
{
    public static string GetOrCreate(IConfiguration cfg, string configKey, string fileName, Func<string> generator)
    {
        var fromCfg = cfg[configKey];
        if (!string.IsNullOrWhiteSpace(fromCfg)) return fromCfg;

        try
        {
            var projectDir = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", ".."));
            var dir = Directory.Exists(Path.Combine(projectDir, "Properties"))
                ? Path.Combine(projectDir, "App_Data")
                : Path.Combine(AppContext.BaseDirectory, "App_Data");

            Directory.CreateDirectory(dir);
            var path = Path.Combine(dir, fileName);
            if (File.Exists(path)) return File.ReadAllText(path).Trim();
            var value = generator();
            File.WriteAllText(path, value);
            return value;
        }
        catch
        {
            return generator();
        }
    }

    public static string RandomToken(int bytes = 48) => Convert.ToBase64String(RandomNumberGenerator.GetBytes(bytes));

    public static string RandomPassword()
    {
        // Always satisfies the password policy (upper, lower, digit).
        var bytes = RandomNumberGenerator.GetBytes(9);
        return "Fh" + Convert.ToHexString(bytes).ToLowerInvariant() + "A1";
    }
}

public class JwtOptions
{
    public string Issuer { get; set; } = "FirstHome.Api";
    public string Audience { get; set; } = "FirstHome.Web";
    public int ExpiryMinutes { get; set; } = 120;
    public string Key { get; set; } = "";
}

public class JwtService(JwtOptions opts)
{
    public (string token, DateTime expires) Create(User user)
    {
        var expires = DateTime.UtcNow.AddMinutes(opts.ExpiryMinutes);
        var creds = new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(opts.Key)),
            SecurityAlgorithms.HmacSha256);
        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Role, user.Role.ToString()),
            new Claim(ClaimTypes.Name, user.FullName),
        };
        var jwt = new JwtSecurityToken(opts.Issuer, opts.Audience, claims, expires: expires, signingCredentials: creds);
        return (new JwtSecurityTokenHandler().WriteToken(jwt), expires);
    }
}

public static class ClaimsExtensions
{
    public static int UserId(this ClaimsPrincipal p) =>
        int.Parse(p.FindFirstValue(ClaimTypes.NameIdentifier) ?? throw new UnauthorizedAccessException());

    public static bool IsAdmin(this ClaimsPrincipal p) => p.IsInRole(nameof(UserRole.Admin));
}

// ---------- Structured errors ----------
public record ApiError(int Status, string Code, string Message, Dictionary<string, string[]>? Errors = null,
    string? TraceId = null);

public class ApiException(int status, string code, string message, Dictionary<string, string[]>? errors = null)
    : Exception(message)
{
    public int Status { get; } = status;
    public string Code { get; } = code;
    public Dictionary<string, string[]>? Errors { get; } = errors;

    public static ApiException NotFound(string message = "Resource not found.") => new(404, "not_found", message);
    public static ApiException Conflict(string message, string field) =>
        new(409, "conflict", message, new() { [field] = [message] });
    public static ApiException Forbidden(string message = "You do not have access to this resource.") =>
        new(403, "forbidden", message);
    public static ApiException Unprocessable(string message, string field) =>
        new(422, "invalid_operation", message, new() { [field] = [message] });
}

public class ErrorHandlingMiddleware(RequestDelegate next, ILogger<ErrorHandlingMiddleware> log)
{
    public async Task Invoke(HttpContext ctx)
    {
        try { await next(ctx); }
        catch (ApiException ex)
        {
            await Write(ctx, new ApiError(ex.Status, ex.Code, ex.Message, ex.Errors, ctx.TraceIdentifier));
        }
        catch (Exception ex)
        {
            // Never leak internals or request bodies (which may contain passwords) to the client or logs.
            log.LogError(ex, "Unhandled error on {Method} {Path}", ctx.Request.Method, ctx.Request.Path);
            await Write(ctx, new ApiError(500, "server_error", "An unexpected error occurred.", null, ctx.TraceIdentifier));
        }
    }

    public static async Task Write(HttpContext ctx, ApiError err)
    {
        if (ctx.Response.HasStarted) return;
        ctx.Response.StatusCode = err.Status;
        ctx.Response.ContentType = "application/json";
        await ctx.Response.WriteAsJsonAsync(err);
    }
}

public static class Mapping
{
    public static IActionResult ValidationResponse(ActionContext ctx)
    {
        var errors = ctx.ModelState.Where(kv => kv.Value!.Errors.Count > 0)
            .ToDictionary(
                kv => JsonNamingPolicy_CamelCase(kv.Key.TrimStart('$', '.')),
                kv => kv.Value!.Errors.Select(e =>
                    string.IsNullOrWhiteSpace(e.ErrorMessage) || e.ErrorMessage.StartsWith("The JSON value")
                        ? "Invalid value." : e.ErrorMessage).ToArray());
        return new ObjectResult(new ApiError(400, "validation_failed", "One or more fields are invalid.", errors,
            ctx.HttpContext.TraceIdentifier))
        { StatusCode = 400 };
    }

    private static string JsonNamingPolicy_CamelCase(string s) =>
        string.IsNullOrEmpty(s) ? s : char.ToLowerInvariant(s[0]) + s[1..];

    public static UserDto ToDto(this User u) => new(u.Id, u.FullName, u.Email, u.Phone, u.Role.ToString(),
        u.CustomerProfile?.State, u.CustomerProfile?.City, u.CustomerProfile?.ContactPreference.ToString(),
        u.CustomerProfile?.ConsentAt, u.ProviderProfile?.Id, u.CreatedAt);

    public static ProviderDto ToDto(this ProviderProfile p) => new(p.Id, p.DisplayName, p.ContactEmail,
        p.User.Phone, p.CategoryId, p.Category.Name, p.State, p.City, p.Description, p.IsActive,
        p.VerificationStatus.ToString(), p.CreatedAt, p.UserId);

    public static LeadDto ToDto(this Lead l, bool withHistory = false) => new(l.Id, l.Reference, l.EnquiryType,
        l.Title, l.Description, l.State, l.City, l.PreferredContact.ToString(), l.Status.ToString(), l.CategoryId,
        l.Category?.Name, l.ProviderId, l.Provider?.DisplayName, l.CustomerUserId, l.Customer.FullName,
        l.Customer.Email, l.CreatedAt, l.UpdatedAt,
        withHistory
            ? l.History.OrderBy(h => h.ChangedAt).ThenBy(h => h.Id).Select(h => new HistoryDto(h.Id,
                h.OldStatus?.ToString(), h.NewStatus.ToString(), h.ChangedByUserId, h.ChangedBy.FullName,
                h.ChangedAt)).ToList()
            : null);

    public static VerificationEventDto ToDto(this VerificationEvent v) => new(v.Id, v.UserId, v.User.FullName,
        v.User.Role.ToString(), v.ProviderType, v.Status.ToString(), v.SimulatedReference, v.Note, v.CreatedAt);

    public static PagedResult<T> Paged<T>(List<T> items, int page, int size, int total) =>
        new(items, page, size, total, (int)Math.Ceiling(total / (double)size));

    public static (int page, int size) Clamp(int page, int size) =>
        (Math.Max(1, page), Math.Clamp(size, 1, 50));
}
