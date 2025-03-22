using Microsoft.EntityFrameworkCore;
using WorkHelpers.Context;

namespace secondarybackendservice;
public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        // Add services to the container.

        builder.Services.AddDbContext<WorkDbContext>(options =>
        {
            options.UseSqlite("Data Source=../databse.dat");

            //options.UseNpgsql(builder.Configuration.GetConnectionString("Docker-Database"));

            //Use SQL Server
            //options.UseSqlServer(builder.Configuration.GetConnectionString("SQL_Server_Database"));
        });
        builder.Services.AddControllers();
            builder.Services.AddCors(options =>
         {
             options.AddPolicy("AllowAll", builder =>
             {
                 builder.AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader();
             });
         });

        var app = builder.Build();

        // Configure the HTTP request pipeline.

        //app.UseHttpsRedirection();
        app.UseCors("AllowAll");
        app.UseAuthorization();


        app.MapControllers();

        app.Run();
    }
}
