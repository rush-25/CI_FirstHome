using System.ComponentModel.DataAnnotations;
using FirstHome.Api.Domain;

namespace FirstHome.Api.Dtos;

public static class Rules
{
    public const string PhonePattern = @"^\+?[0-9][0-9 \-]{6,18}$";
    public const string PasswordPattern = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,64}$";
    public const string PasswordMessage = "Password must be 8-64 characters with upper-case, lower-case and a digit.";
}

// ---------- Auth ----------
public class RegisterRequest
{
    [Required, StringLength(120, MinimumLength = 2)] public string FullName { get; set; } = "";
    [Required, EmailAddress, StringLength(160)] public string Email { get; set; } = "";
    [Required, RegularExpression(Rules.PhonePattern, ErrorMessage = "Enter a valid phone number (synthetic numbers only).")]
    public string Phone { get; set; } = "";
    [Required, RegularExpression(Rules.PasswordPattern, ErrorMessage = Rules.PasswordMessage)]
    public string Password { get; set; } = "";
    /// <summary>Customer or Provider. Admin accounts cannot be self-registered.</summary>
    [Required] public UserRole? Role { get; set; }
    [StringLength(60)] public string? State { get; set; }
    [StringLength(80)] public string? City { get; set; }
    public ContactMethod? ContactPreference { get; set; }
    [Required] public bool Consent { get; set; }
}

public class LoginRequest
{
    [Required, EmailAddress] public string Email { get; set; } = "";
    [Required] public string Password { get; set; } = "";
}

public record AuthResponse(string Token, DateTime ExpiresAt, UserDto User);

public record UserDto(int Id, string FullName, string Email, string Phone, string Role,
    string? State, string? City, string? ContactPreference, DateTime? ConsentAt, int? ProviderId,
    DateTime CreatedAt);

public class UpdateMeRequest
{
    [Required, StringLength(120, MinimumLength = 2)] public string FullName { get; set; } = "";
    [Required, RegularExpression(Rules.PhonePattern, ErrorMessage = "Enter a valid phone number (synthetic numbers only).")]
    public string Phone { get; set; } = "";
    [StringLength(60)] public string? State { get; set; }
    [StringLength(80)] public string? City { get; set; }
    public ContactMethod? ContactPreference { get; set; }
}

// ---------- Categories / providers ----------
public record CategoryDto(int Id, string Name, string Slug, bool IsActive);

public class ProviderRequest
{
    [Required, StringLength(120, MinimumLength = 2)] public string DisplayName { get; set; } = "";
    [Required, EmailAddress, StringLength(160)] public string ContactEmail { get; set; } = "";
    [Required] public int? CategoryId { get; set; }
    [Required, StringLength(60)] public string State { get; set; } = "";
    [Required, StringLength(80)] public string City { get; set; } = "";
    [Required, StringLength(1000, MinimumLength = 10)] public string Description { get; set; } = "";
}

public record ProviderDto(int Id, string DisplayName, string ContactEmail, string Phone, int CategoryId,
    string CategoryName, string State, string City, string Description, bool IsActive,
    string VerificationStatus, DateTime CreatedAt, int UserId);

// ---------- Leads ----------
public class CreateLeadRequest
{
    [Required, StringLength(60, MinimumLength = 3)] public string EnquiryType { get; set; } = "";
    [Required, StringLength(150, MinimumLength = 5)] public string Title { get; set; } = "";
    [Required, StringLength(2000, MinimumLength = 10)] public string Description { get; set; } = "";
    [Required, StringLength(60)] public string State { get; set; } = "";
    [Required, StringLength(80)] public string City { get; set; } = "";
    [Required] public ContactMethod? PreferredContact { get; set; }
    public int? CategoryId { get; set; }
    public int? ProviderId { get; set; }
}

public record HistoryDto(int Id, string? OldStatus, string NewStatus, int ChangedByUserId,
    string ChangedByName, DateTime ChangedAt);

public record LeadDto(int Id, string Reference, string EnquiryType, string Title, string Description,
    string State, string City, string PreferredContact, string Status, int? CategoryId, string? CategoryName,
    int? ProviderId, string? ProviderName, int CustomerUserId, string CustomerName, string CustomerEmail,
    DateTime CreatedAt, DateTime UpdatedAt, List<HistoryDto>? History);

public class UpdateLeadStatusRequest
{
    [Required] public LeadStatus? Status { get; set; }
}

// ---------- Admin / verification ----------
public class MockVerificationRequest
{
    [Required] public VerificationStatus? Status { get; set; }
    [StringLength(250)] public string? Note { get; set; }
}

public record VerificationEventDto(int Id, int UserId, string UserName, string UserRole, string ProviderType,
    string Status, string SimulatedReference, string? Note, DateTime CreatedAt);

public record VerificationStateDto(string Status, string ProviderType, bool ConsentGiven,
    List<VerificationEventDto> Events, string Disclaimer);

public class SetActiveRequest { [Required] public bool? IsActive { get; set; } }

public record CustomerRowDto(int Id, string FullName, string Email, string Phone, string? State, string? City,
    bool IsActive, int LeadCount, string VerificationStatus, DateTime CreatedAt);

public record ProviderRowDto(int Id, int UserId, string DisplayName, string OwnerName, string Email,
    string CategoryName, string State, string City, bool IsActive, string VerificationStatus, DateTime CreatedAt);

public record SummaryDto(int TotalCustomers, int TotalProviders, int ActiveProviders, int TotalLeads,
    Dictionary<string, int> LeadsByStatus, List<LeadDto> RecentLeads, List<ProviderRowDto> RecentProviders,
    List<VerificationEventDto> RecentVerificationEvents);

public record PagedResult<T>(List<T> Items, int Page, int PageSize, int Total, int TotalPages);
