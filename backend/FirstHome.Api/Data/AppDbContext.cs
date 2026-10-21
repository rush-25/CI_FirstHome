using FirstHome.Api.Domain;
using Microsoft.EntityFrameworkCore;

namespace FirstHome.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<CustomerProfile> CustomerProfiles => Set<CustomerProfile>();
    public DbSet<ProviderProfile> ProviderProfiles => Set<ProviderProfile>();
    public DbSet<ServiceCategory> ServiceCategories => Set<ServiceCategory>();
    public DbSet<Lead> Leads => Set<Lead>();
    public DbSet<LeadStatusHistory> LeadStatusHistory => Set<LeadStatusHistory>();
    public DbSet<VerificationEvent> VerificationEvents => Set<VerificationEvent>();

    protected override void ConfigureConventions(ModelConfigurationBuilder cb)
    {
        cb.Properties<DateTime>().HaveConversion<UtcConverter>();
        cb.Properties<DateTime?>().HaveConversion<NullableUtcConverter>();
    }

    private class UtcConverter() : Microsoft.EntityFrameworkCore.Storage.ValueConversion.ValueConverter<DateTime, DateTime>(
        v => v.Kind == DateTimeKind.Local ? v.ToUniversalTime() : v, v => DateTime.SpecifyKind(v, DateTimeKind.Utc));

    private class NullableUtcConverter() : Microsoft.EntityFrameworkCore.Storage.ValueConversion.ValueConverter<DateTime?, DateTime?>(
        v => v.HasValue && v.Value.Kind == DateTimeKind.Local ? v.Value.ToUniversalTime() : v,
        v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : v);

    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<User>(e =>
        {
            e.HasIndex(x => x.Email).IsUnique();
            e.Property(x => x.FullName).HasMaxLength(120).IsRequired();
            e.Property(x => x.Email).HasMaxLength(160).IsRequired();
            e.Property(x => x.Phone).HasMaxLength(30).IsRequired();
            e.Property(x => x.PasswordHash).HasMaxLength(100).IsRequired();
            e.Property(x => x.Role).HasConversion<string>().HasMaxLength(20);
        });

        b.Entity<CustomerProfile>(e =>
        {
            e.HasKey(x => x.UserId);
            e.HasOne(x => x.User).WithOne(u => u.CustomerProfile)
                .HasForeignKey<CustomerProfile>(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
            e.Property(x => x.State).HasMaxLength(60);
            e.Property(x => x.City).HasMaxLength(80);
            e.Property(x => x.ContactPreference).HasConversion<string>().HasMaxLength(20);
        });

        b.Entity<ServiceCategory>(e =>
        {
            e.HasIndex(x => x.Slug).IsUnique();
            e.Property(x => x.Name).HasMaxLength(80).IsRequired();
            e.Property(x => x.Slug).HasMaxLength(80).IsRequired();
        });

        b.Entity<ProviderProfile>(e =>
        {
            e.HasOne(x => x.User).WithOne(u => u.ProviderProfile)
                .HasForeignKey<ProviderProfile>(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
            e.HasIndex(x => x.UserId).IsUnique();
            e.HasOne(x => x.Category).WithMany().HasForeignKey(x => x.CategoryId).OnDelete(DeleteBehavior.Restrict);
            e.Property(x => x.DisplayName).HasMaxLength(120).IsRequired();
            e.Property(x => x.ContactEmail).HasMaxLength(160);
            e.Property(x => x.State).HasMaxLength(60);
            e.Property(x => x.City).HasMaxLength(80);
            e.Property(x => x.Description).HasMaxLength(1000);
            e.Property(x => x.VerificationStatus).HasConversion<string>().HasMaxLength(20);
            e.HasIndex(x => new { x.IsActive, x.CategoryId, x.State });
        });

        b.Entity<Lead>(e =>
        {
            e.HasIndex(x => x.Reference).IsUnique();
            e.HasIndex(x => x.Status);
            e.HasOne(x => x.Customer).WithMany().HasForeignKey(x => x.CustomerUserId).OnDelete(DeleteBehavior.Restrict);
            e.HasOne(x => x.Provider).WithMany().HasForeignKey(x => x.ProviderId).OnDelete(DeleteBehavior.NoAction);
            e.HasOne(x => x.Category).WithMany().HasForeignKey(x => x.CategoryId).OnDelete(DeleteBehavior.NoAction);
            e.Property(x => x.Reference).HasMaxLength(20).IsRequired();
            e.Property(x => x.EnquiryType).HasMaxLength(60).IsRequired();
            e.Property(x => x.Title).HasMaxLength(150).IsRequired();
            e.Property(x => x.Description).HasMaxLength(2000).IsRequired();
            e.Property(x => x.State).HasMaxLength(60);
            e.Property(x => x.City).HasMaxLength(80);
            e.Property(x => x.PreferredContact).HasConversion<string>().HasMaxLength(20);
            e.Property(x => x.Status).HasConversion<string>().HasMaxLength(20);
        });

        b.Entity<LeadStatusHistory>(e =>
        {
            e.HasOne(x => x.Lead).WithMany(l => l.History).HasForeignKey(x => x.LeadId).OnDelete(DeleteBehavior.Cascade);
            e.HasOne(x => x.ChangedBy).WithMany().HasForeignKey(x => x.ChangedByUserId).OnDelete(DeleteBehavior.Restrict);
            e.Property(x => x.OldStatus).HasConversion<string>().HasMaxLength(20);
            e.Property(x => x.NewStatus).HasConversion<string>().HasMaxLength(20);
        });

        b.Entity<VerificationEvent>(e =>
        {
            e.HasOne(x => x.User).WithMany().HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
            e.Property(x => x.ProviderType).HasMaxLength(10);
            e.Property(x => x.Status).HasConversion<string>().HasMaxLength(20);
            e.Property(x => x.SimulatedReference).HasMaxLength(40);
            e.Property(x => x.Note).HasMaxLength(250);
        });
    }

    public override int SaveChanges(bool acceptAllChangesOnSuccess)
    {
        Touch();
        return base.SaveChanges(acceptAllChangesOnSuccess);
    }

    public override Task<int> SaveChangesAsync(bool acceptAllChangesOnSuccess, CancellationToken ct = default)
    {
        Touch();
        return base.SaveChangesAsync(acceptAllChangesOnSuccess, ct);
    }

    /// <summary>Maintain updated_at automatically for modified entities.</summary>
    private void Touch()
    {
        foreach (var entry in ChangeTracker.Entries().Where(e => e.State == EntityState.Modified))
        {
            switch (entry.Entity)
            {
                case User u: u.UpdatedAt = DateTime.UtcNow; break;
                case ProviderProfile p: p.UpdatedAt = DateTime.UtcNow; break;
                case Lead l: l.UpdatedAt = DateTime.UtcNow; break;
            }
        }
    }
}
