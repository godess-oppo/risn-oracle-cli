type Job = { id: string; type: string; payload: any; };
export class Queue {
  jobs: Job[] = [];
  enqueue(job: Job) { this.jobs.push(job); }
  dequeue(): Job | undefined { return this.jobs.shift(); }
}
