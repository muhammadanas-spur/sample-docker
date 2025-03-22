using workhelpers.Models;

namespace workhelpers;

public static class WorkHelperService
{
    // Get the list of work items in alphabetical order
    public static List<WorkItem> GetTasks(List<WorkItem> workItemsList)
    {
        return workItemsList.OrderBy(t => t.Title).ToList();
    }
}
