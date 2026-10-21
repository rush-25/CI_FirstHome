using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using FirstHome.Api.Data;
using FirstHome.Api.Domain;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace FirstHome.Tests;

public class ApiFactory : WebApplicationFactory<Program>
{
    public const string AdminPw = "AdminPass1";
    public const string DemoPw = "DemoPass1";
    private readonly string _db = "fh-" + Guid.NewGuid();

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.UseSetting("Jwt:Key", "test-only-signing-key-test-only-signing-key-0123456789");
        builder.ConfigureTestServices(s =>
        {
            s.AddDbContext<AppDbContext>(o => o.UseInMemoryDatabase(_db));
        });
    }

    public async Task SeedAsync()
    {
        using var scope = Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await Seeder.SeedAsync(db, AdminPw, DemoPw);
    }
}

public class ApiTests : IDisposable
{
    private readonly ApiFactory _f = new();

    public ApiTests()
    {
        _f.SeedAsync().GetAwaiter().GetResult();
    }

    public void Dispose() => _f.Dispose();

    private async Task<HttpClient> LoginAsync(string email, string pw)
    {
        var c = _f.CreateClient();
        var r = await c.PostAsJsonAsync("/api/auth/login", new { email, password = pw });
        r.EnsureSuccessStatusCode();
        var doc = await r.Content.ReadFromJsonAsync<JsonElement>();
        c.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", doc.GetProperty("token").GetString());
        return c;
    }

    private Task<HttpClient> Admin() => LoginAsync(Seeder.AdminEmail, ApiFactory.AdminPw);

    private static object NewCustomer(string email) => new
    {
        fullName = "Test Customer", email, phone = "+234 800 555 0101", password = "Passw0rdX",
        role = "Customer", state = "Lagos", city = "Ikeja", contactPreference = "Phone", consent = true,
    };

    // AT-01
    [Fact]
    public async Task Customer_can_register_login_create_lead_and_see_it_again()
    {
        var anon = _f.CreateClient();
        var reg = await anon.PostAsJsonAsync("/api/auth/register", NewCustomer("at01@test.dev"));
        Assert.Equal(HttpStatusCode.Created, reg.StatusCode);

        var c = await LoginAsync("at01@test.dev", "Passw0rdX");
        var create = await c.PostAsJsonAsync("/api/leads", new
        {
            enquiryType = "Service request", title = "Fix kitchen tap", description = "Tap is leaking badly.",
            state = "Lagos", city = "Ikeja", preferredContact = "Phone",
        });
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);
        var lead = await create.Content.ReadFromJsonAsync<JsonElement>();
        Assert.StartsWith("FH-", lead.GetProperty("reference").GetString());

        var c2 = await LoginAsync("at01@test.dev", "Passw0rdX"); // "log out and back in"
        var mine = await c2.GetFromJsonAsync<JsonElement>("/api/leads/mine");
        Assert.Equal(1, mine.GetProperty("total").GetInt32());
    }

    // AT-02
    [Fact]
    public async Task New_provider_appears_in_filtered_directory()
    {
        var anon = _f.CreateClient();
        var reg = await anon.PostAsJsonAsync("/api/auth/register", new
        {
            fullName = "Prov Owner", email = "prov-at02@test.dev", phone = "+234 800 555 0102",
            password = "Passw0rdX", role = "Provider", consent = true,
        });
        Assert.Equal(HttpStatusCode.Created, reg.StatusCode);
        var p = await LoginAsync("prov-at02@test.dev", "Passw0rdX");
        var create = await p.PostAsJsonAsync("/api/providers", new
        {
            displayName = "Zed Fixers", contactEmail = "zed@test.dev", categoryId = 1, state = "Imo", city = "Owerri",
            description = "We fix all manner of household plumbing.",
        });
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);

        var hit = await anon.GetFromJsonAsync<JsonElement>("/api/providers?state=Imo&category=1");
        Assert.Equal(1, hit.GetProperty("total").GetInt32());
        var miss = await anon.GetFromJsonAsync<JsonElement>("/api/providers?state=Imo&category=2");
        Assert.Equal(0, miss.GetProperty("total").GetInt32());
    }

    // AT-03 + AT-04
    [Fact]
    public async Task Admin_changes_status_history_stored_customer_sees_it_and_counts_change()
    {
        var admin = await Admin();
        var before = await admin.GetFromJsonAsync<JsonElement>("/api/admin/summary");
        var totalBefore = before.GetProperty("totalLeads").GetInt32();

        var anon = _f.CreateClient();
        await anon.PostAsJsonAsync("/api/auth/register", NewCustomer("at03@test.dev"));
        var c = await LoginAsync("at03@test.dev", "Passw0rdX");
        var created = await (await c.PostAsJsonAsync("/api/leads", new
        {
            enquiryType = "Service request", title = "Paint the fence", description = "Two coats of white paint.",
            state = "Lagos", city = "Ikeja", preferredContact = "Email",
        })).Content.ReadFromJsonAsync<JsonElement>();
        var id = created.GetProperty("id").GetInt32();

        var after = await admin.GetFromJsonAsync<JsonElement>("/api/admin/summary");
        Assert.Equal(totalBefore + 1, after.GetProperty("totalLeads").GetInt32());

        var patch = await admin.PatchAsJsonAsync($"/api/admin/leads/{id}/status", new { status = "Contacted" });
        Assert.Equal(HttpStatusCode.OK, patch.StatusCode);

        var detail = await c.GetFromJsonAsync<JsonElement>($"/api/leads/{id}");
        Assert.Equal("Contacted", detail.GetProperty("status").GetString());
        Assert.Equal(2, detail.GetProperty("history").GetArrayLength());

        using var scope = _f.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        Assert.Contains(db.LeadStatusHistory, h => h.LeadId == id && h.OldStatus == LeadStatus.New && h.NewStatus == LeadStatus.Contacted);

        // Invalid transition is rejected
        var bad = await admin.PatchAsJsonAsync($"/api/admin/leads/{id}/status", new { status = "New" });
        Assert.Equal((HttpStatusCode)422, bad.StatusCode);
    }

    // AT-05
    [Fact]
    public async Task Validation_duplicate_email_and_password_hashing()
    {
        var anon = _f.CreateClient();
        Assert.Equal(HttpStatusCode.Created, (await anon.PostAsJsonAsync("/api/auth/register", NewCustomer("dup@test.dev"))).StatusCode);
        var dup = await anon.PostAsJsonAsync("/api/auth/register", NewCustomer("dup@test.dev"));
        Assert.Equal(HttpStatusCode.Conflict, dup.StatusCode);

        var invalid = await anon.PostAsJsonAsync("/api/auth/register", new
        {
            fullName = "", email = "not-an-email", phone = "abc", password = "short", role = "Customer", consent = false,
        });
        Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);
        var body = await invalid.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal("validation_failed", body.GetProperty("code").GetString());
        Assert.True(body.GetProperty("errors").TryGetProperty("email", out _));

        using var scope = _f.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var hash = db.Users.First(u => u.Email == "dup@test.dev").PasswordHash;
        Assert.NotEqual("Passw0rdX", hash);
        Assert.StartsWith("$2", hash);

        var wrong = await anon.PostAsJsonAsync("/api/auth/login", new { email = "dup@test.dev", password = "wrong" });
        Assert.Equal(HttpStatusCode.Unauthorized, wrong.StatusCode);
    }

    // AT-06
    [Theory]
    [InlineData("/api/admin/summary")]
    [InlineData("/api/admin/leads")]
    [InlineData("/api/admin/customers")]
    [InlineData("/api/admin/providers")]
    public async Task Admin_routes_deny_anonymous_and_customer(string url)
    {
        var anon = _f.CreateClient();
        Assert.Equal(HttpStatusCode.Unauthorized, (await anon.GetAsync(url)).StatusCode);
        var cust = await LoginAsync(Seeder.CustomerEmail(1), ApiFactory.DemoPw);
        Assert.Equal(HttpStatusCode.Forbidden, (await cust.GetAsync(url)).StatusCode);
    }

    [Fact]
    public async Task Customer_cannot_patch_status_or_read_other_customers_lead()
    {
        var cust = await LoginAsync(Seeder.CustomerEmail(1), ApiFactory.DemoPw);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await cust.PatchAsJsonAsync("/api/admin/leads/1/status", new { status = "Contacted" })).StatusCode);
        // Lead 2 belongs to customer 2
        Assert.Equal(HttpStatusCode.NotFound, (await cust.GetAsync("/api/leads/2")).StatusCode);
    }

    [Fact]
    public async Task Mock_verification_flow_and_seed_counts()
    {
        var admin = await Admin();
        var s = await admin.GetFromJsonAsync<JsonElement>("/api/admin/summary");
        Assert.Equal(10, s.GetProperty("totalCustomers").GetInt32());
        Assert.Equal(8, s.GetProperty("totalProviders").GetInt32());
        Assert.Equal(15, s.GetProperty("totalLeads").GetInt32());

        var r = await admin.PostAsJsonAsync("/api/admin/users/1/mock-verification", new { status = "Verified" });
        // user 1 is the admin -> invalid operation
        Assert.Equal((HttpStatusCode)422, r.StatusCode);

        var cust = await LoginAsync(Seeder.CustomerEmail(3), ApiFactory.DemoPw);
        var consent = await cust.PostAsync("/api/me/verification/consent", null);
        Assert.Equal(HttpStatusCode.OK, consent.StatusCode);
        var me = await cust.GetFromJsonAsync<JsonElement>("/api/me");
        var uid = me.GetProperty("id").GetInt32();
        var ok = await admin.PostAsJsonAsync($"/api/admin/users/{uid}/mock-verification", new { status = "Verified" });
        Assert.Equal(HttpStatusCode.OK, ok.StatusCode);
        var state = await cust.GetFromJsonAsync<JsonElement>("/api/me/verification");
        Assert.Equal("Verified", state.GetProperty("status").GetString());
        Assert.Equal("MOCK", state.GetProperty("providerType").GetString());
    }
}
