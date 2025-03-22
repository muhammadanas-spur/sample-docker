using System.Net;
using System.Threading.Tasks;
using primarybackendservice.Configuration;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using workhelpers.Models;
using WorkHelpers.Context;

namespace primarybackendservice.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class WorkItemController : ControllerBase
    {
        // private static List<WorkItem> workItemsList = new List<WorkItem>();
        private readonly WorkDbContext _dbContext;
        private readonly ServiceEndpointSettings _serviceEndpoints;

        public WorkItemController(
            WorkDbContext dbContext,
            IOptions<ServiceEndpointSettings> serviceEndpoints
            )
        {
            _dbContext = dbContext;
            _serviceEndpoints = serviceEndpoints.Value;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<WorkItem>>> GetTasks()
        {
            var workItems = await _dbContext.WorkItems.ToListAsync();
            return Ok(workItems);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<WorkItem>> GetTask(int id)
        {
            WorkItem? workItem = await _dbContext.WorkItems.FindAsync(id);
            if (workItem == null)
            {
                return NotFound();
            }
            return Ok(workItem);
        }

        [HttpPost]
        public async Task<ActionResult<WorkItem>> CreateTask(WorkItem workItem)
        {
            // workItem.Id = workItemsList.Count > 0 ? workItemsList.Max(t => t.Id) + 1 : 1;
            await _dbContext.WorkItems.AddAsync(workItem);
            await _dbContext.SaveChangesAsync();
            return CreatedAtAction(nameof(GetTask), new { id = workItem.Id }, workItem);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> UpdateTask(int id, WorkItem updatedTask)
        {
            var task = await _dbContext.WorkItems.FindAsync(id);
            if (task == null)
            {
                return NotFound();
            }

            task.Title = updatedTask.Title;
            task.Completed = updatedTask.Completed;
            await _dbContext.SaveChangesAsync();
            return NoContent();

            // var task = workItemsList.FirstOrDefault(t => t.Id == id);
            // if (task == null)
            // {
            //     return NotFound();
            // }
            // task.Title = updatedTask.Title;
            // task.Completed = updatedTask.Completed;
            // return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> DeleteTask(int id)
        {
            using (var httpClient = new HttpClient())
            {
                var response = await httpClient.DeleteAsync($"{_serviceEndpoints.SecondService}/api/SecondService/{id}");
                if (response.IsSuccessStatusCode)
                {
                    return Ok();
                }
                else if (response.StatusCode == HttpStatusCode.NotFound)
                {
                    return NotFound();
                }
                else
                {
                    return StatusCode((int)response.StatusCode, response.ReasonPhrase);
                }
            }
        }
    }
}