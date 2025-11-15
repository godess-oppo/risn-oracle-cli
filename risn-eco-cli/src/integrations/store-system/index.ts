import axios from "axios";
import { loadConfig } from "@utils/fs.js";

export class StoreSystem {
  private baseUrl: string;
  private apiKey: string;
  constructor() {
    const cfg = loadConfig();
    this.baseUrl = cfg.store.baseUrl || "";
    this.apiKey = cfg.store.apiKey || "";
  }
  async createEvent(event: any) {
    return axios.post(`${this.baseUrl}/api/events`, event, { headers: { "X-API-Key": this.apiKey } }).then(r => r.data);
  }
  async notifyMerch(payload: any) {
    return axios.post(`${this.baseUrl}/api/merch/notify`, payload, { headers: { "X-API-Key": this.apiKey } }).then(r => r.data);
  }
}
export const StoreBuilder = {
  createCapsule: (capsule: any) => capsule,
};
