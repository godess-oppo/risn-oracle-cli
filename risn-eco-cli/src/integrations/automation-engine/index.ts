export class AutomationEngine {
  private listeners: Record<string, Function[]> = {};
  on(event: string, cb: Function) {
    this.listeners[event] = this.listeners[event] || [];
    this.listeners[event].push(cb);
  }
  emit(event: string, payload: any) {
    (this.listeners[event] || []).forEach(cb => cb(payload));
  }
}
