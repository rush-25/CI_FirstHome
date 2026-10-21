namespace FirstHome.Api.Domain;

public enum UserRole { Customer, Provider, Admin }

public enum LeadStatus { New, Contacted, Qualified, Closed }

public enum VerificationStatus { NotStarted, Pending, Verified, Rejected }

public enum ContactMethod { Phone, Email, WhatsApp }

public class User
{
    public int Id { get; set; }
    public string FullName { get; set; } = "";
    public string Email { get; set; } = "";
    public string Phone { get; set; } = "";
    public string PasswordHash { get; set; } = "";
    public UserRole Role { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public CustomerProfile? CustomerProfile { get; set; }
    public ProviderProfile? ProviderProfile { get; set; }
}

public class CustomerProfile
{
    // PK is also the FK to Users (1:1).
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public string State { get; set; } = "";
    public string City { get; set; } = "";
    public ContactMethod ContactPreference { get; set; } = ContactMethod.Phone;
    public DateTime ConsentAt { get; set; }
}

public class ServiceCategory
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string Slug { get; set; } = "";
    public bool IsActive { get; set; } = true;
}

public class ProviderProfile
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public string DisplayName { get; set; } = "";
    public string ContactEmail { get; set; } = "";
    public int CategoryId { get; set; }
    public ServiceCategory Category { get; set; } = null!;
    public string State { get; set; } = "";
    public string City { get; set; } = "";
    public string Description { get; set; } = "";
    public bool IsActive { get; set; } = true;
    public VerificationStatus VerificationStatus { get; set; } = VerificationStatus.NotStarted;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

public class Lead
{
    public int Id { get; set; }
    /// <summary>Human friendly reference e.g. FH-2026-0015</summary>
    public string Reference { get; set; } = "";
    public int CustomerUserId { get; set; }
    public User Customer { get; set; } = null!;
    public int? ProviderId { get; set; }
    public ProviderProfile? Provider { get; set; }
    public int? CategoryId { get; set; }
    public ServiceCategory? Category { get; set; }
    public string EnquiryType { get; set; } = "";
    public string Title { get; set; } = "";
    public string Description { get; set; } = "";
    public string State { get; set; } = "";
    public string City { get; set; } = "";
    public ContactMethod PreferredContact { get; set; }
    public LeadStatus Status { get; set; } = LeadStatus.New;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public List<LeadStatusHistory> History { get; set; } = new();
}

public class LeadStatusHistory
{
    public int Id { get; set; }
    public int LeadId { get; set; }
    public Lead Lead { get; set; } = null!;
    /// <summary>Null for the initial creation entry.</summary>
    public LeadStatus? OldStatus { get; set; }
    public LeadStatus NewStatus { get; set; }
    public int ChangedByUserId { get; set; }
    public User ChangedBy { get; set; } = null!;
    public DateTime ChangedAt { get; set; } = DateTime.UtcNow;
}

/// <summary>MOCK verification only. No BVN/NIN or identity document is ever stored.</summary>
public class VerificationEvent
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public string ProviderType { get; set; } = "MOCK";
    public VerificationStatus Status { get; set; }
    public string SimulatedReference { get; set; } = "";
    public string? Note { get; set; }
    public int? CreatedByUserId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
