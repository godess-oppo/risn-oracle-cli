import fs from "fs";
import { fingerprintItem } from "@ai/fashion-genome/utils/fingerprint.js";

export type ClosetItem = {
  id: string;
  name: string;
  category: "top" | "bottom" | "dress" | "outerwear" | "shoes" | "acc";
  color: string;
  silhouette?: string;
  texture?: string;
  vibe?: string;
  brand?: string;
  vectorId?: string;
  vector?: number[];
  usage: number;
  lastWorn?: number;
};

export class ClosetTelemetry {
  items: ClosetItem[] = [];
  async mapFromFile(path?: string) {
    const dataPath = path || "./data/closet.json";
    const raw = JSON.parse(fs.readFileSync(dataPath, "utf8"));
    const mapped: ClosetItem[] = [];
    for (const it of raw.items) {
      const fp = await fingerprintItem(it.imageUrl);
      mapped.push({
        id: it.id,
        name: it.name,
        category: it.category,
        color: it.color,
        silhouette: it.silhouette,
        texture: it.texture,
        vibe: it.vibe,
        brand: it.brand,
        vectorId: fp.id,
        vector: fp.embedding,
        usage: it.usage || 0,
        lastWorn: it.lastWorn || 0
      });
    }
    this.items = mapped;
    fs.writeFileSync("./.risn/data/closet-index.json", JSON.stringify(mapped, null, 2));
    return mapped;
  }
  async computeEfficiency() {
    const avgUsage = this.items.reduce((a, b) => a + (b.usage || 0), 0) / (this.items.length || 1);
    const score = Math.min(1, avgUsage / 30);
    return { wardrobeEfficiencyScore: score, avgUsage };
  }
}
