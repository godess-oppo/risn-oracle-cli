import fs from "fs";
import path from "path";
import ical from "node-ical";
import { CapsuleBuilder } from "@integrations/store-system/builder.js";
import { StoreSystem } from "@integrations/store-system/index.js";
import { EventBus } from "@integrations/automation-engine/event-bus.js";

export const EventPrediction = {
  async scanCalendar(icsPath?: string) {
    const events: any[] = [];
    if (icsPath && fs.existsSync(icsPath)) {
      const data = ical.sync.parseFile(icsPath);
      Object.values(data).forEach((e: any) => {
        if (e.type === "VEVENT") {
          const type = inferEventType(e.summary || "");
          events.push({
            id: e.uid,
            title: e.summary,
            date: e.start,
            type,
            palette: defaultPalette(type),
            silhouette: defaultSilhouette(type)
          });
        }
      });
    }
    return events;
  },
  async buildCapsules() {
    const events = await EventPrediction.scanCalendar();
    const capsules = events.map(ev => CapsuleBuilder.fromEvent(ev));
    const dir = path.join(process.cwd(), "data", "seeds");
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(dir, "capsules.json"), JSON.stringify(capsules, null, 2));
    return capsules;
  },
  async notifyStore() {
    const bus = new EventBus();
    const store = new StoreSystem();
    const capsulesPath = path.join(process.cwd(), "data", "seeds", "capsules.json");
    if (!fs.existsSync(capsulesPath)) await EventPrediction.buildCapsules();
    const capsules = JSON.parse(fs.readFileSync(capsulesPath, "utf8"));
    for (const c of capsules) await store.createEvent({ type: "capsule", data: c });
    bus.publish("capsule.published", { count: capsules.length });
    return { ok: true, capsules };
  }
};

function inferEventType(title: string) {
  const t = title.toLowerCase();
  if (t.includes("wedding")) return "wedding";
  if (t.includes("interview")) return "interview";
  if (t.includes("travel")) return "travel";
  if (t.includes("holiday")) return "holiday";
  return "general";
}
function defaultPalette(type: string) {
  switch (type) {
    case "wedding": return ["ivory", "champagne", "blush"];
    case "interview": return ["navy", "white", "charcoal"];
    case "travel": return ["khaki", "ink", "teal"];
    case "holiday": return ["emerald", "crimson", "gold"];
    default: return ["black", "white", "gray"];
  }
}
function defaultSilhouette(type: string) {
  switch (type) {
    case "wedding": return ["flowy", "tailored"];
    case "interview": return ["tailored", "crisp"];
    case "travel": return ["relaxed", "versatile"];
    case "holiday": return ["draped", "statement"];
    default: return ["classic"];
  }
}
