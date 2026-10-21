using FirstHome.Api.Data;
using FirstHome.Api.Domain;
using FirstHome.Api.Dtos;
using FirstHome.Api.Infrastructure;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FirstHome.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(AppDbContext db, JwtService jwt) : ControllerBase
{
    /// <summary>Register a Customer or Provider account (Admin cannot be self-registered).</summary>
    [HttpPost("register")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(AuthResponse), 201)]
    public async Task<IActionResult> Register(RegisterRequest req)
    {
        var errors = new Dictionary<string, string[]>();
        if (req.Role == UserRole.Admin) throw ApiException.Forbidden("Admin accounts cannot be self-registered.");
        if (!req.Consent) errors["consent"] = ["You must accept the terms and consent to continue."];
        if (req.Role == UserRole.Customer)
        {
            if (string.IsNullOrWhiteSpace(req.State)) errors["state"] = ["State is required."];
            if (string.IsNullOrWhiteSpace(req.City)) errors["city"] = ["City is required."];
        }
        if (errors.Count > 0)
            throw new ApiException(400, "validation_failed", "One or more fields are invalid.", errors);

        var email = req.Email.Trim().ToLowerInvariant();
        if (await db.Users.AnyAsync(u => u.Email == email))
            throw ApiException.Conflict("An account with this email already exists.", "email");

        var user = new User
        {
            FullName = req.FullName.Trim(),
            Email = email,
            Phone = req.Phone.Trim(),
            Role = req.Role!.Value,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password, 11),
        };
        if (user.Role == UserRole.Customer)
            user.CustomerProfile = new CustomerProfile
            {
                State = req.State!.Trim(), City = req.City!.Trim(),
                ContactPreference = req.ContactPreference ?? ContactMethod.Phone,
                ConsentAt = DateTime.UtcNow,
            };
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var (token, exp) = jwt.Create(user);
        return StatusCode(201, new AuthResponse(token, exp, user.ToDto()));
    }

    [HttpPost("login")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(AuthResponse), 200)]
    public async Task<IActionResult> Login(LoginRequest req)
    {
        var email = req.Email.Trim().ToLowerInvariant();
        var user = await db.Users.Include(u => u.CustomerProfile).Include(u => u.ProviderProfile)
            .FirstOrDefaultAsync(u => u.Email == email);
        // Same message for unknown email / wrong password to avoid account enumeration.
        if (user is null || !BCrypt.Net.BCrypt.Verify(req.Password, user.PasswordHash) || !user.IsActive)
            throw new ApiException(401, "invalid_credentials", "Invalid email or password.");
        var (token, exp) = jwt.Create(user);
        return Ok(new AuthResponse(token, exp, user.ToDto()));
    }
}

[ApiController]
[Route("api/me")]
[Authorize]
public class MeController(AppDbContext db) : ControllerBase
{
    private Task<User> Load() => db.Users.Include(u => u.CustomerProfile).Include(u => u.ProviderProfile)
        .FirstAsync(u => u.Id == User.UserId());

    [HttpGet]
    public async Task<UserDto> Get() => (await Load()).ToDto();

    [HttpPut]
    public async Task<UserDto> Update(UpdateMeRequest req)
    {
        var user = await Load();
        user.FullName = req.FullName.Trim();
        user.Phone = req.Phone.Trim();
        if (user.CustomerProfile is { } cp)
        {
            var errors = new Dictionary<string, string[]>();
            if (string.IsNullOrWhiteSpace(req.State)) errors["state"] = ["State is required."];
            if (string.IsNullOrWhiteSpace(req.City)) errors["city"] = ["City is required."];
            if (errors.Count > 0)
                throw new ApiException(400, "validation_failed", "One or more fields are invalid.", errors);
            cp.State = req.State!.Trim();
            cp.City = req.City!.Trim();
            if (req.ContactPreference is { } cm) cp.ContactPreference = cm;
        }
        await db.SaveChangesAsync();
        return user.ToDto();
    }

    /// <summary>Current MOCK verification state plus history for the signed-in user.</summary>
    [HttpGet("verification")]
    public async Task<VerificationStateDto> Verification()
    {
        var id = User.UserId();
        var events = await db.VerificationEvents.Include(v => v.User).Where(v => v.UserId == id)
            .OrderByDescending(v => v.CreatedAt).ThenByDescending(v => v.Id).ToListAsync();
        return new VerificationStateDto(events.FirstOrDefault()?.Status.ToString() ?? nameof(VerificationStatus.NotStarted),
            "MOCK", events.Count > 0, events.Select(e => e.ToDto()).ToList(), VerificationInfo.Disclaimer);
    }

    /// <summary>Consent to a MOCK verification. Moves state to Pending. No identity data is collected.</summary>
    [HttpPost("verification/consent")]
    public async Task<VerificationStateDto> Consent()
    {
        var id = User.UserId();
        var role = User.IsInRole("Admin");
        if (role) throw ApiException.Forbidden("Admins do not take part in verification.");
        var last = await db.VerificationEvents.Where(v => v.UserId == id)
            .OrderByDescending(v => v.CreatedAt).ThenByDescending(v => v.Id).FirstOrDefaultAsync();
        if (last is not null && last.Status is VerificationStatus.Pending or VerificationStatus.Verified)
            throw ApiException.Unprocessable("Verification is already " + last.Status + ".", "status");
        await VerificationInfo.Record(db, id, VerificationStatus.Pending, id, "User consented to MOCK verification.");
        return await Verification();
    }
}

public static class VerificationInfo
{
    public const string Disclaimer =
        "Demo verification only - no real identity checks. No BVN, NIN or identity documents are requested or stored.";

    public static async Task<VerificationEvent> Record(AppDbContext db, int userId, VerificationStatus status,
        int? actorId, string? note)
    {
        var ev = new VerificationEvent
        {
            UserId = userId, Status = status, ProviderType = "MOCK", CreatedByUserId = actorId, Note = note,
            SimulatedReference = "MOCK-" + Guid.NewGuid().ToString("N")[..10].ToUpperInvariant(),
        };
        db.VerificationEvents.Add(ev);
        var provider = await db.ProviderProfiles.FirstOrDefaultAsync(p => p.UserId == userId);
        if (provider is not null) provider.VerificationStatus = status;
        await db.SaveChangesAsync();
        return ev;
    }
}
