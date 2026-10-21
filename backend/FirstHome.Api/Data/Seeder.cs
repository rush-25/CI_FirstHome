using FirstHome.Api.Domain;
using Microsoft.EntityFrameworkCore;

namespace FirstHome.Api.Data;

/// <summary>All seeded people/companies are fictional and clearly marked SAMPLE.</summary>
public static class Seeder
{
    public const string AdminEmail = "admin@sample.firsthome.test";
    public static string CustomerEmail(int n) => $"customer{n:D2}@sample.firsthome.test";
    public static string ProviderEmail(int n) => $"provider{n:D2}@sample.firsthome.test";

    public static async Task SeedAsync(AppDbContext db, string adminPassword, string demoPassword)
    {
        if (await db.Users.AnyAsync()) return;

        var now = DateTime.UtcNow;
        var adminHash = BCrypt.Net.BCrypt.HashPassword(adminPassword, 11);
        var demoHash = BCrypt.Net.BCrypt.HashPassword(demoPassword, 11);

        var cats = new[]
        {
            "Plumbing", "Electrical Services", "Home Cleaning", "Carpentry", "Painting",
            "Air Conditioning & HVAC", "Appliance Repairs", "Moving Services", "Home Maintenance",
        }.Select(n => new ServiceCategory { Name = n, Slug = Slug(n) }).ToList();
        db.ServiceCategories.AddRange(cats);

        var admin = new User
        {
            FullName = "FirstHome Admin (SAMPLE)", Email = AdminEmail, Phone = "+234 800 000 0000",
            Role = UserRole.Admin, PasswordHash = adminHash, CreatedAt = now.AddDays(-60),
        };
        db.Users.Add(admin);

        var customerData = new (string Name, string State, string City, ContactMethod Pref)[]
        {
            ("Adaeze Okafor", "Lagos", "Ikeja", ContactMethod.Phone),
            ("Tunde Bakare", "Lagos", "Lekki", ContactMethod.WhatsApp),
            ("Ngozi Eze", "Abuja (FCT)", "Wuse", ContactMethod.Email),
            ("Emeka Nwosu", "Rivers", "Port Harcourt", ContactMethod.Phone),
            ("Fatima Bello", "Kano", "Nasarawa", ContactMethod.WhatsApp),
            ("Chidi Okeke", "Lagos", "Yaba", ContactMethod.Email),
            ("Amina Yusuf", "Abuja (FCT)", "Garki", ContactMethod.Phone),
            ("Segun Adeyemi", "Oyo", "Ibadan", ContactMethod.Phone),
            ("Blessing Udo", "Akwa Ibom", "Uyo", ContactMethod.WhatsApp),
            ("Ifeanyi Obi", "Enugu", "Independence Layout", ContactMethod.Email),
        };
        var customers = new List<User>();
        for (var i = 0; i < customerData.Length; i++)
        {
            var c = customerData[i];
            var u = new User
            {
                FullName = $"{c.Name} (SAMPLE)", Email = CustomerEmail(i + 1), Phone = $"+234 800 100 {i + 1:D4}",
                Role = UserRole.Customer, PasswordHash = demoHash, CreatedAt = now.AddDays(-45 + i * 3),
                CustomerProfile = new CustomerProfile
                {
                    State = c.State, City = c.City, ContactPreference = c.Pref, ConsentAt = now.AddDays(-45 + i * 3),
                },
            };
            customers.Add(u);
        }
        db.Users.AddRange(customers);

        // category index, business, owner, state, city, description
        var providerData = new (int Cat, string Biz, string Owner, string State, string City, string Desc)[]
        {
            (0, "Lagos Pipe Masters", "Olu Adebayo", "Lagos", "Ikeja", "Leak repairs, bathroom fittings and borehole plumbing for homes and small offices."),
            (1, "BrightWire Electricals", "Kelechi Anyanwu", "Lagos", "Lekki", "Rewiring, inverter installation, fault tracing and lighting upgrades."),
            (2, "SparkleHome Cleaners", "Funmi Alabi", "Abuja (FCT)", "Wuse", "Deep cleaning, post-construction cleaning and recurring home cleaning plans."),
            (3, "Craftline Carpentry", "Ibrahim Lawal", "Kano", "Nasarawa", "Custom wardrobes, doors, kitchen cabinets and furniture repair."),
            (4, "ColourCrest Painters", "Grace Etim", "Rivers", "Port Harcourt", "Interior and exterior painting, screeding and wall finishing."),
            (5, "CoolBreeze HVAC", "Sani Danjuma", "Abuja (FCT)", "Garki", "Air conditioner installation, servicing and gas refilling."),
            (6, "FixIt Appliance Care", "Chinedu Ibe", "Lagos", "Yaba", "Repairs for fridges, washing machines, cookers and microwaves."),
            (7, "SwiftMove Logistics", "Bola Salami", "Oyo", "Ibadan", "Local house moves, packing services and careful furniture handling."),
        };
        var providers = new List<ProviderProfile>();
        for (var i = 0; i < providerData.Length; i++)
        {
            var p = providerData[i];
            var status = i switch
            {
                0 or 1 or 4 => VerificationStatus.Verified,
                2 or 5 => VerificationStatus.Pending,
                3 => VerificationStatus.Rejected,
                _ => VerificationStatus.NotStarted,
            };
            var user = new User
            {
                FullName = $"{p.Owner} (SAMPLE)", Email = ProviderEmail(i + 1), Phone = $"+234 800 200 {i + 1:D4}",
                Role = UserRole.Provider, PasswordHash = demoHash, CreatedAt = now.AddDays(-40 + i * 4),
            };
            var profile = new ProviderProfile
            {
                User = user, DisplayName = $"{p.Biz} (SAMPLE)", ContactEmail = user.Email, Category = cats[p.Cat],
                State = p.State, City = p.City, Description = p.Desc, IsActive = true,
                VerificationStatus = status, CreatedAt = user.CreatedAt,
            };
            providers.Add(profile);
        }
        db.ProviderProfiles.AddRange(providers);

        // Verification events (MOCK) for providers with a non-default status.
        var evCounter = 1;
        foreach (var p in providers.Where(p => p.VerificationStatus != VerificationStatus.NotStarted))
        {
            var steps = p.VerificationStatus switch
            {
                VerificationStatus.Verified => new[] { VerificationStatus.Pending, VerificationStatus.Verified },
                VerificationStatus.Rejected => new[] { VerificationStatus.Pending, VerificationStatus.Rejected },
                _ => new[] { VerificationStatus.Pending },
            };
            var d = 20;
            foreach (var s in steps)
            {
                db.VerificationEvents.Add(new VerificationEvent
                {
                    User = p.User, Status = s, ProviderType = "MOCK",
                    SimulatedReference = $"MOCK-SAMPLE{evCounter++:D4}",
                    Note = s == VerificationStatus.Pending ? "Provider consented to MOCK verification (SAMPLE)."
                        : "Simulated outcome (SAMPLE).",
                    CreatedByUserId = null, CreatedAt = now.AddDays(-d--),
                });
            }
        }

        await db.SaveChangesAsync();

        // 15 leads across statuses. (customerIdx, providerIdx|-1, catIdx, type, title, status)
        var leadData = new (int C, int P, int Cat, string Type, string Title, LeadStatus S)[]
        {
            (0, 0, 0, "Service request", "Kitchen sink leaking under cabinet", LeadStatus.New),
            (1, 1, 1, "Service request", "Rewire two bedrooms before move-in", LeadStatus.Contacted),
            (2, 2, 2, "Service request", "Deep clean after renovation", LeadStatus.Qualified),
            (3, 4, 4, "Service request", "Repaint 3-bedroom flat interior", LeadStatus.Closed),
            (4, 3, 3, "Service request", "Build-in wardrobe for master bedroom", LeadStatus.New),
            (5, 6, 6, "Service request", "Washing machine not draining", LeadStatus.Contacted),
            (6, 5, 5, "Service request", "Install two split-unit ACs", LeadStatus.New),
            (7, 7, 7, "Housing enquiry", "Move from Ibadan to Lagos next month", LeadStatus.Qualified),
            (8, -1, 8, "Housing enquiry", "General maintenance for rented duplex", LeadStatus.New),
            (9, -1, 0, "Service request", "Replace water heater connection", LeadStatus.Closed),
            (0, 1, 1, "Service request", "Install inverter and change breaker box", LeadStatus.Contacted),
            (1, 0, 0, "Service request", "Bathroom fittings replacement", LeadStatus.New),
            (2, -1, 5, "Housing enquiry", "Looking for HVAC maintenance contract", LeadStatus.Contacted),
            (3, 6, 6, "Service request", "Fridge cooling issue", LeadStatus.Qualified),
            (4, 2, 2, "Service request", "Weekly cleaning plan quote", LeadStatus.New),
        };
        for (var i = 0; i < leadData.Length; i++)
        {
            var l = leadData[i];
            var c = customers[l.C];
            var created = now.AddDays(-25 + i * 1.5);
            var lead = new Lead
            {
                Reference = $"FH-{created.Year}-{i + 1:D4}", Customer = c, Category = cats[l.Cat],
                Provider = l.P >= 0 ? providers[l.P] : null, EnquiryType = l.Type, Title = l.Title,
                Description = "SAMPLE enquiry created for demonstration. " + l.Title + " - please share an estimate.",
                State = c.CustomerProfile!.State, City = c.CustomerProfile.City,
                PreferredContact = c.CustomerProfile.ContactPreference, Status = l.S, CreatedAt = created,
                UpdatedAt = created,
            };
            // Build history path to the final status.
            var path = new List<LeadStatus> { LeadStatus.New };
            if (l.S == LeadStatus.Contacted) path.Add(LeadStatus.Contacted);
            if (l.S == LeadStatus.Qualified) path.AddRange([LeadStatus.Contacted, LeadStatus.Qualified]);
            if (l.S == LeadStatus.Closed) path.AddRange([LeadStatus.Contacted, LeadStatus.Closed]);
            LeadStatus? prev = null;
            var t = created;
            foreach (var s in path)
            {
                lead.History.Add(new LeadStatusHistory
                {
                    OldStatus = prev, NewStatus = s, ChangedBy = prev is null ? c : admin, ChangedAt = t,
                });
                prev = s;
                t = t.AddHours(20);
            }
            lead.UpdatedAt = t.AddHours(-20);
            db.Leads.Add(lead);
        }
        await db.SaveChangesAsync();
    }

    public static string Slug(string name) =>
        new string(name.ToLowerInvariant().Replace("&", "and").Select(c => char.IsLetterOrDigit(c) ? c : '-').ToArray())
            .Replace("--", "-").Replace("--", "-").Trim('-');
}

