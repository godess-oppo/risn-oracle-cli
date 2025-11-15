import { Queue } from "./queue.js";
export const WorkerPool = {
  queues: { default: new Queue() },
  start() { console.log("Worker pool started"); }
};
