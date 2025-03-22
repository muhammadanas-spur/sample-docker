using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using workhelpers.Models;

namespace WorkHelpers.Context
{
    public class WorkDbContext : DbContext
    {
        public WorkDbContext(DbContextOptions<WorkDbContext> options) : base(options)
        {
        }

        // protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        // {
        //     string dbConString = _configuration.GetConnectionString("Database") ?? 
        //     throw new InvalidOperationException("Connection string"
        // + "'Database' not found.");

        //     optionsBuilder.UseNpgsql(dbConString);
        //     // base.OnConfiguring(optionsBuilder);
        // }

        // Define your DbSets here. For example:
        public DbSet<WorkItem> WorkItems { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure your entity mappings here. For example:
            modelBuilder.Entity<WorkItem>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Title).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Completed).IsRequired();
                // Add other configurations as needed
            });
        }
    }
}