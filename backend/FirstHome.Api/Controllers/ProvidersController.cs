using FirstHome.Api.Data;
using FirstHome.Api.Domain;
using FirstHome.Api.Dtos;
using FirstHome.Api.Infrastructure;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FirstHome.Api.Controllers;

[ApiController]
[Route("api/categories")]
public class CategoriesController(AppDbContext db) : ControllerBase
{
    [HttpGet, AllowAnonymous]
    public async Task<List<CategoryDto>> List() =>
        await db.ServiceCategories.Where(c => c.IsActive).OrderBy(c => c.Name)
            .Select(c => new CategoryDto(c.Id, c.Name, c.Slug, c.IsActive)).ToListAsync();
}

[ApiController]
[Route("api/providers")]
public class ProvidersController(AppDbContext db) : ControllerBase
{
    private IQueryable<ProviderProfile> Query() =>
        db.ProviderProfiles.Include(p => p.User).Include(p => p.Category);

    /// <summary>Public directory. Only active providers are discoverable.</summary>
    [HttpGet, AllowAnonymous]
    public async Task<PagedResult<ProviderDto>> List([FromQuery] int? category, [FromQuery] string? state,
        [FromQuery] string? city, [FromQuery] string? q, [FromQuery] string sort = "name",
        [FromQuery] int page = 1, [FromQuery] int pageSize = 9)
    {
        (page, pageSize) = Mapping.Clamp(page, pageSize);
        var query = Query().Where(p => p.IsActive);
        if (category is not null) query = query.Where(p => p.CategoryId == category);
        if (!string.IsNullOrWhiteSpace(state)) query = query.Where(p => p.State == state);
        if (!string.IsNullOrWhiteSpace(city)) query = query.Where(p => p.City == city);
        if (!string.IsNullOrWhiteSpace(q))
        {
            var term = q.Trim();
            query = query.Where(p => p.DisplayName.Contains(term) || p.Description.Contains(term)
                                     || p.Category.Name.Contains(term) || p.City.Contains(term));
        }
        query = sort == "newest" ? query.OrderByDescending(p => p.CreatedAt) : query.OrderBy(p => p.DisplayName);
        var total = await query.CountAsync();
        var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
        return Mapping.Paged(items.Select(p => p.ToDto()).ToList(), page, pageSize, total);
    }

    /// <summary>The signed-in provider's own profile (404 when not yet created).</summary>
    [HttpGet("me"), Authorize(Roles = "Provider")]
    public async Task<ProviderDto> Mine()
    {
        var p = await Query().FirstOrDefaultAsync(x => x.UserId == User.UserId())
                ?? throw ApiException.NotFound("You have not created a provider profile yet.");
        return p.ToDto();
    }

    /// <summary>Leads addressed directly to the signed-in provider (read-only).</summary>
    [HttpGet("me/leads"), Authorize(Roles = "Provider")]
    public async Task<List<LeadDto>> MyLeads()
    {
        var uid = User.UserId();
        var leads = await db.Leads.Include(l => l.Customer).Include(l => l.Category).Include(l => l.Provider)
            .Where(l => l.Provider!.UserId == uid).OrderByDescending(l => l.CreatedAt).ToListAsync();
        // Providers only see first name + enquiry content, never email.
        return leads.Select(l => l.ToDto() with
        {
            CustomerEmail = "", CustomerName = l.Customer.FullName.Split(' ')[0]
        }).ToList();
    }

    [HttpGet("{id:int}"), AllowAnonymous]
    public async Task<ProviderDto> Get(int id)
    {
        var p = await Query().FirstOrDefaultAsync(x => x.Id == id) ?? throw ApiException.NotFound("Provider not found.");
        var canSeeInactive = User.Identity?.IsAuthenticated == true && (User.IsAdmin() || p.UserId == User.UserId());
        if (!p.IsActive && !canSeeInactive) throw ApiException.NotFound("Provider not found.");
        return p.ToDto();
    }

    [HttpPost, Authorize(Roles = "Provider")]
    public async Task<IActionResult> Create(ProviderRequest req)
    {
        var uid = User.UserId();
        if (await db.ProviderProfiles.AnyAsync(p => p.UserId == uid))
            throw ApiException.Conflict("You already have a provider profile. Update it instead.", "provider");
        await EnsureCategory(req.CategoryId!.Value);
        var p = new ProviderProfile { UserId = uid };
        Apply(p, req);
        // Latest mock verification state (if any) carries over.
        var last = await db.VerificationEvents.Where(v => v.UserId == uid).OrderByDescending(v => v.Id).FirstOrDefaultAsync();
        if (last is not null) p.VerificationStatus = last.Status;
        db.ProviderProfiles.Add(p);
        await db.SaveChangesAsync();
        var created = await Query().FirstAsync(x => x.Id == p.Id);
        return CreatedAtAction(nameof(Get), new { id = p.Id }, created.ToDto());
    }

    [HttpPut("{id:int}"), Authorize(Roles = "Provider,Admin")]
    public async Task<ProviderDto> Update(int id, ProviderRequest req)
    {
        var p = await Query().FirstOrDefaultAsync(x => x.Id == id) ?? throw ApiException.NotFound("Provider not found.");
        if (!User.IsAdmin() && p.UserId != User.UserId())
            throw ApiException.Forbidden("You can only update your own provider profile.");
        await EnsureCategory(req.CategoryId!.Value);
        Apply(p, req);
        await db.SaveChangesAsync();
        return (await Query().FirstAsync(x => x.Id == id)).ToDto();
    }

    private async Task EnsureCategory(int id)
    {
        if (!await db.ServiceCategories.AnyAsync(c => c.Id == id && c.IsActive))
            throw new ApiException(400, "validation_failed", "One or more fields are invalid.",
                new() { ["categoryId"] = ["Choose a valid service category."] });
    }

    private static void Apply(ProviderProfile p, ProviderRequest r)
    {
        p.DisplayName = r.DisplayName.Trim();
        p.ContactEmail = r.ContactEmail.Trim().ToLowerInvariant();
        p.CategoryId = r.CategoryId!.Value;
        p.State = r.State.Trim();
        p.City = r.City.Trim();
        p.Description = r.Description.Trim();
    }
}
