using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using WorkHelpers.Context;

namespace secondarybackendservice.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SecondServiceController : ControllerBase
{
    private readonly WorkDbContext _dbContext;
    public SecondServiceController(WorkDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteTask(int id)
    {
        var task = await _dbContext.WorkItems.FindAsync(id);
        if (task == null)
        {
            return NotFound();
        }
        _dbContext.WorkItems.Remove(task);
        await _dbContext.SaveChangesAsync();
        return Ok();
    }
}
