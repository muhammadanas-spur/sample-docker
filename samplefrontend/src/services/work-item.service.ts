import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { catchError, Observable } from 'rxjs';
import { environment } from 'src/environments/environment';

export interface WorkItem {
    id: number;
    title: string;
    completed: boolean;
}

@Injectable({
    providedIn: 'root'
})
export class WorkItemService {
    // private apiUrl = 'http://localhost:5264/api/workitem';
    // private apiUrl = 'https://localhost:7023/api/workitem';
    private apiUrl = `${environment.baseUrl}/api/workitem`;

    constructor(private http: HttpClient) { }

    getTasks(): Observable<WorkItem[]> {
        return this.http.get<WorkItem[]>(this.apiUrl);
    }

    getTask(id: number): Observable<WorkItem> {
        return this.http.get<WorkItem>(`${this.apiUrl}/${id}`);
    }

    createTask(workItem: WorkItem): Observable<WorkItem> {
        return this.http.post<WorkItem>(this.apiUrl, workItem)
            .pipe(
                catchError(err => {
                    console.error(err);
                    return [];
                })
            );
    }

    updateTask(id: number, workItem: WorkItem): Observable<void> {
        return this.http.put<void>(`${this.apiUrl}/${id}`, workItem);
    }

    deleteTask(id: number): Observable<void> {
        return this.http.delete<void>(`${this.apiUrl}/${id}`);
    }
}