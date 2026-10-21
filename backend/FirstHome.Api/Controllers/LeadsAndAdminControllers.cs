using FirstHome.Api.Data;
using FirstHome.Api.Domain;
using FirstHome.Api.Dtos;
using FirstHome.Api.Infrastructure;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FirstHome.Api.Controllers;

public static class LeadRules
{
    /// <summary>Allowed lead status transitions (New -> Contacted -> Qualified, any open state -> Closed).</summary>
    public static readonly Dictionary<LeadStatus, LeadStatus[]> Transitions = new()
    {
        [LeadStatus.New] = [LeadStatus.Contacted, LeadStatus.Closed],
        [LeadStatus.Contacted] = [LeadStatus.Qualified, LeadStatus.Closed],
        [LeadStatus.Qualified] = [LeadStatus.Closed],
        [LeadStatus.Closed] = [],
    };
}

[ApiController]
[Route("api/leads")]
[Authorize]
public class LeadsController(AppDbContext db) : ControllerBase
{
    private IQueryable<Lead> Query() => db.Leads.Include(l => l.Customer).Include(l => l.Category)
        .Include(l => l.Provider);

    [HttpPost, Authorize(Roles = "Customer")]
    public async Task<IActionResult> Create(CreateLeadRequest req)
    {
        var errors = new Dictionary<string, string[]>();
        if (req.CategoryId is not null && !await db.ServiceCategories.AnyAsync(c => c.Id == req.CategoryId && c.IsActive))
            errors["categoryId"] = ["Choose a valid service category."];
        if (req.ProviderId is not null && !await db.ProviderProfiles.AnyAsync(p => p.Id == req.ProviderId && p.IsActive))
            errors["providerId"] = ["The selected provider is not available."];
        if (errors.Count > 0)
            throw new ApiException(400, "validation_failed", "One or more fields are invalid.", errors);

        var uid = User.UserId();
        var lead = new Lead
        {
            Reference = "TMP-" + Guid.NewGuid().ToString("N")[..12],
            CustomerUserId = uid, EnquiryType = req.EnquiryType.Trim(), Title = req.Title.Trim(),
            Description = req.Description.Trim(), State = req.State.Trim(), City = req.City.Trim(),
            PreferredContact = req.PreferredContact!.Value, CategoryId = req.CategoryId, ProviderId = req.ProviderId,
            Status = LeadStatus.New,
        };
        lead.History.Add(new LeadStatusHistory { OldStatus = null, NewStatus = LeadStatus.New, ChangedByUserId = uid });
        db.Leads.Add(lead);
        await db.SaveChangesAsync();
        lead.Reference = $"FH-{lead.CreatedAt.Year}-{lead.Id:D4}";
        await db.SaveChangesAsync();

        var created = await Query().Include(l => l.History).ThenInclude(h => h.ChangedBy).FirstAsync(l => l.Id == lead.Id);
        return CreatedAtAction(nameof(Get), new { id = lead.Id }, created.ToDto(true));
    }

    /// <summary>The signed-in customer's own leads only.</summary>
    [HttpGet("mine"), Authorize(Roles = "Customer")]
    public async Task<PagedResult<LeadDto>> Mine([FromQuery] string? status, [FromQuery] string? q,
        [FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        (page, pageSize) = Mapping.Clamp(page, pageSize);
        var uid = User.UserId();
        var query = Query().Where(l => l.CustomerUserId == uid);
        if (Enum.TryParse<LeadStatus>(status, true, out var st)) query = query.Where(l => l.Status == st);
        if (!string.IsNullOrWhiteSpace(q))
            query = query.Where(l => l.Reference.Contains(q.Trim()) || l.Title.Contains(q.Trim()));
        var total = await query.CountAsync();
        var items = await query.OrderByDescending(l => l.CreatedAt).Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
        return Mapping.Paged(items.Select(l => l.ToDto()).ToList(), page, pageSize, total);
    }

    /// <summary>Lead details with history. Customers may only open their own; admins any.</summary>
    [HttpGet("{id:int}")]
    public async Task<LeadDto> Get(int id)
    {
        var lead = await Query().Include(l => l.History).ThenInclude(h => h.ChangedBy)
            .FirstOrDefaultAsync(l => l.Id == id) ?? throw ApiException.NotFound("Lead not found.");
        if (!User.IsAdmin() && lead.CustomerUserId != User.UserId())
            throw ApiException.NotFound("Lead not found."); // do not reveal existence of others' records
        return lead.ToDto(true);
    }
}

[ApiController]
[Route("api/admin")]
[Authorize(Roles = "Admin")]
public class AdminController(AppDbContext db) : ControllerBase
{
    [HttpGet("summary")]
    public async Task<SummaryDto> Summary()
    {
        var byStatus = await db.Leads.GroupBy(l => l.Status).Select(g => new { g.Key, C = g.Count() }).ToListAsync();
        var dict = Enum.GetValues<LeadStatus>().ToDictionary(s => s.ToString(),
            s => byStatus.FirstOrDefault(x => x.Key == s)?.C ?? 0);
        var recentLeads = await db.Leads.Include(l => l.Customer).Include(l => l.Category).Include(l => l.Provider)
            .OrderByDescending(l => l.CreatedAt).Take(5).ToListAsync();
        var recentProviders = await db.ProviderProfiles.Include(p => p.User).Include(p => p.Category)
            .OrderByDescending(p => p.CreatedAt).Take(5).ToListAsync();
        var recentEvents = await db.VerificationEvents.Include(v => v.User)
            .OrderByDescending(v => v.CreatedAt).ThenByDescending(v => v.Id).Take(5).ToListAsync();
        return new SummaryDto(
            await db.Users.CountAsync(u => u.Role == UserRole.Customer),
            await db.ProviderProfiles.CountAsync(),
            await db.ProviderProfiles.CountAsync(p => p.IsActive),
            await db.Leads.CountAsync(), dict,
            recentLeads.Select(l => l.ToDto()).ToList(),
            recentProviders.Select(ProviderRow).ToList(),
            recentEvents.Select(e => e.ToDto()).ToList());
    }

    private static ProviderRowDto ProviderRow(ProviderProfile p) => new(p.Id, p.UserId, p.DisplayName,
        p.User.FullName, p.User.Email, p.Category.Name, p.State, p.City, p.IsActive,
        p.VerificationStatus.ToString(), p.CreatedAt);

    [HttpGet("customers")]
    public async Task<PagedResult<CustomerRowDto>> Customers([FromQuery] string? q, [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
    {
        (page, pageSize) = Mapping.Clamp(page, pageSize);
        var query = db.Users.Include(u => u.CustomerProfile).Where(u => u.Role == UserRole.Customer);
        if (!string.IsNullOrWhiteSpace(q))
            query = query.Where(u => u.FullName.Contains(q.Trim()) || u.Email.Contains(q.Trim()));
        var total = await query.CountAsync();
        var users = await query.OrderByDescending(u => u.CreatedAt).Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
        var ids = users.Select(u => u.Id).ToList();
        var counts = await db.Leads.Where(l => ids.Contains(l.CustomerUserId)).GroupBy(l => l.CustomerUserId)
            .Select(g => new { g.Key, C = g.Count() }).ToListAsync();
        var latest = await db.VerificationEvents.Where(v => ids.Contains(v.UserId)).ToListAsync();
        var rows = users.Select(u => new CustomerRowDto(u.Id, u.FullName, u.Email, u.Phone,
            u.CustomerProfile?.State, u.CustomerProfile?.City, u.IsActive,
            counts.FirstOrDefault(c => c.Key == u.Id)?.C ?? 0,
            latest.Where(v => v.UserId == u.Id).OrderByDescending(v => v.Id).FirstOrDefault()?.Status.ToString()
                ?? nameof(VerificationStatus.NotStarted), u.CreatedAt)).ToList();
        return Mapping.Paged(rows, page, pageSize, total);
    }

    [HttpGet("providers")]
    public async Task<PagedResult<ProviderRowDto>> Providers([FromQuery] string? q, [FromQuery] int? category,
        [FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        (page, pageSize) = Mapping.Clamp(page, pageSize);
        var query = db.ProviderProfiles.Include(p => p.User).Include(p => p.Category).AsQueryable();
        if (category is not null) query = query.Where(p => p.CategoryId == category);
        if (!string.IsNullOrWhiteSpace(q))
            query = query.Where(p => p.DisplayName.Contains(q.Trim()) || p.User.FullName.Contains(q.Trim())
                                     || p.User.Email.Contains(q.Trim()));
        var total = await query.CountAsync();
        var items = await query.OrderByDescending(p => p.CreatedAt).Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
        return Mapping.Paged(items.Select(ProviderRow).ToList(), page, pageSize, total);
    }

    /// <summary>Activate/deactivate a provider (inactive providers disappear from the public directory).</summary>
    [HttpPatch("providers/{id:int}/active")]
    public async Task<ProviderRowDto> SetActive(int id, SetActiveRequest req)
    {
        var p = await db.ProviderProfiles.Include(x => x.User).Include(x => x.Category).FirstOrDefaultAsync(x => x.Id == id)
                ?? throw ApiException.NotFound("Provider not found.");
        p.IsActive = req.IsActive!.Value;
        await db.SaveChangesAsync();
        return ProviderRow(p);
    }

    [HttpGet("leads")]
    public async Task<PagedResult<LeadDto>> Leads([FromQuery] string? status, [FromQuery] string? q,
        [FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        (page, pageSize) = Mapping.Clamp(page, pageSize);
        var query = db.Leads.Include(l => l.Customer).Include(l => l.Category).Include(l => l.Provider).AsQueryable();
        if (!string.IsNullOrWhiteSpace(status))
        {
            if (!Enum.TryParse<LeadStatus>(status, true, out var st))
                throw new ApiException(400, "validation_failed", "One or more fields are invalid.",
                    new() { ["status"] = ["Unknown lead status."] });
            query = query.Where(l => l.Status == st);
        }
        if (!string.IsNullOrWhiteSpace(q))
        {
            var t = q.Trim();
            query = query.Where(l => l.Reference.Contains(t) || l.Title.Contains(t) || l.Customer.FullName.Contains(t)
                                     || l.Customer.Email.Contains(t));
        }
        var total = await query.CountAsync();
        var items = await query.OrderByDescending(l => l.CreatedAt).Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
        return Mapping.Paged(items.Select(l => l.ToDto()).ToList(), page, pageSize, total);
    }

    [HttpPatch("leads/{id:int}/status")]
    public async Task<LeadDto> ChangeStatus(int id, UpdateLeadStatusRequest req)
    {
        var lead = await db.Leads.Include(l => l.Customer).Include(l => l.Category).Include(l => l.Provider)
            .Include(l => l.History).ThenInclude(h => h.ChangedBy)
            .FirstOrDefaultAsync(l => l.Id == id) ?? throw ApiException.NotFound("Lead not found.");
        var next = req.Status!.Value;
        if (!LeadRules.Transitions[lead.Status].Contains(next))
            throw ApiException.Unprocessable($"Cannot move a lead from {lead.Status} to {next}.", "status");
        var hist = new LeadStatusHistory
        {
            LeadId = lead.Id, OldStatus = lead.Status, NewStatus = next, ChangedByUserId = User.UserId(),
            ChangedAt = DateTime.UtcNow,
        };
        lead.Status = next;
        db.LeadStatusHistory.Add(hist);
        await db.SaveChangesAsync();
        var fresh = await db.Leads.Include(l => l.Customer).Include(l => l.Category).Include(l => l.Provider)
            .Include(l => l.History).ThenInclude(h => h.ChangedBy).FirstAsync(l => l.Id == id);
        return fresh.ToDto(true);
    }

    /// <summary>Allowed next statuses, handy for UI drop-downs.</summary>
    [HttpGet("leads/transitions")]
    public Dictionary<string, string[]> Transitions() =>
        LeadRules.Transitions.ToDictionary(k => k.Key.ToString(), v => v.Value.Select(s => s.ToString()).ToArray());

    /// <summary>Simulate a MOCK verification result. Takes no identifiers at all - never BVN/NIN.</summary>
    [HttpPost("users/{id:int}/mock-verification")]
    public async Task<VerificationEventDto> MockVerification(int id, MockVerificationRequest req)
    {
        var user = await db.Users.FirstOrDefaultAsync(u => u.Id == id) ?? throw ApiException.NotFound("User not found.");
        if (user.Role == UserRole.Admin) throw ApiException.Unprocessable("Admins cannot be verified.", "id");
        var ev = await VerificationInfo.Record(db, id, req.Status!.Value, User.UserId(),
            string.IsNullOrWhiteSpace(req.Note) ? "Simulated by admin (MOCK)." : req.Note.Trim());
        ev.User = user;
        return ev.ToDto();
    }

    [HttpGet("verification-events")]
    public async Task<PagedResult<VerificationEventDto>> Events([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        (page, pageSize) = Mapping.Clamp(page, pageSize);
        var query = db.VerificationEvents.Include(v => v.User);
        var total = await query.CountAsync();
        var items = await query.OrderByDescending(v => v.CreatedAt).ThenByDescending(v => v.Id)
            .Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
        return Mapping.Paged(items.Select(v => v.ToDto()).ToList(), page, pageSize, total);
    }
}
