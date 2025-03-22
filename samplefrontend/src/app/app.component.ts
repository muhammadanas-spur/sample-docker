import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, NgModel } from '@angular/forms';
import { WorkItem, WorkItemService } from 'src/services/work-item.service';
// interface Task {
//   id: number;
//   title: string;
//   completed: boolean;
// }
@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  workItemList: WorkItem[] = [];
  newWorkItemTitle: string = '';

  constructor(private workItemService: WorkItemService) {

  }

  ngOnInit() {
    this.loadWorkItems();
  }

  private loadWorkItems() {
    this.workItemService.getTasks().subscribe(itemList => this.workItemList = itemList);
  }

  addWorkItem() {
    if (this.newWorkItemTitle.trim()) {
      const newWorkItme: WorkItem = {
        id: 0,
        title: this.newWorkItemTitle,
        completed: false
      };

      this.workItemService.createTask(newWorkItme).subscribe(item => {
        this.workItemList.unshift(item);
        this.newWorkItemTitle = '';
      });
    }
  }

  toggleWorkItem(workItem: WorkItem) {
    workItem.completed = !workItem.completed;
    this.workItemService.updateTask(workItem.id, workItem).subscribe();
  }

  editWorkItem(workItem: WorkItem) {
    const newTitle = prompt('Edit workItem:', workItem.title);
    if (newTitle !== null && newTitle.trim()) {
      workItem.title = newTitle;
      this.workItemService.updateTask(workItem.id, workItem).subscribe();
    }
  }

  deleteWorkItem(item: WorkItem) {
    if (confirm('Are you sure you want to delete this task?')) {
      this.workItemService.deleteTask(item.id).subscribe(() => {
        this.workItemList = this.workItemList.filter(t => t.id !== item.id);
      });
    }
  }
}