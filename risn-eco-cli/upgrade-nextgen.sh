#!/usr/bin/env bash
set -e

echo "🚀 Upgrading RISN‑ECO‑CLI with next‑gen modules…"

# -----------------------------------------------------------------
# 0️⃣ Create the new directory structure
# -----------------------------------------------------------------
mkdir -p src/ai/{fashion-genome/utils,body-twin,emotional-weather,event-prediction,closet-telemetry,vectors/store,models/{embeddings,vision},providers}
mkdir -p src/integrations/{store-system,automation-engine}
mkdir -p src/{pipelines,workers,middleware,plugins/samples,api/routes}
mkdir -p src/utils
mkdir -p .risn/data .risn/vectors .risn/plugins

# -----------------------------------------------------------------
# 1️⃣ Core utilities (shared across modules)
# -----------------------------------------------------------------
cat <<'EOF' > src/utils/fs.ts
import fs from "fs";
import path from "path";

export function ensureDir(dir: string) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}
export async function readFile(p: string, enc?: any) {
  return fs.promises.readFile(path.resolve(p), enc);
}
export async function writeFile(p: string, data: any) {
  return fs.promises.writeFile(path.resolve(p), data);
}
export function loadConfig() {
  const cfg = {
    userId: process.env.RISN_USER_ID || "demo-user",
    ai: {
      provider: process.env.RISN_AI_PROVIDER || "openai",
      embeddingModel: process.env.RISN_EMBEDDING_MODEL || "text-embedding-3-small",
      visionModel: process.env.RISN_VISION_MODEL || "gpt-4o-mini",
    },
    store: {
      baseUrl: process.env.RISN_STORE_BASE_URL || "",
      apiKey: process.env.RISN_STORE_API_KEY || "",
    },
    automation: {
      eventBus: process.env.RISN_EVENT_BUS || "memory",
      queue: process.env.RISN_QUEUE || "memory",
    }
  };
  return cfg;
}
EOF

cat <<'EOF' > src/utils/hashing.ts
export function hashString(input: string): string {
  let h = 0, i = 0, len = input.length;
  while (i < len) h = (h << 5) - h + input.charCodeAt(i++) | 0;
  return (h >>> 0).toString(16);
}
EOF

cat <<'EOF' > src/utils/io.ts
export async function readStdin(): Promise<string> {
  return new Promise<string>((resolve) => {
    let data = "";
    process.stdin.on("data", (chunk) => (data += chunk));
    process.stdin.on("end", () => resolve(data));
  });
}
EOF

cat <<'EOF' > src/utils/logging.ts
export const log = {
  info: (...args: any[]) => console.log("[INFO]", ...args),
  warn: (...args: any[]) => console.warn("[WARN]", ...args),
  error: (...args: any[]) => console.error("[ERROR]", ...args)
};
EOF

cat <<'EOF' > src/utils/validators.ts
export function isNonEmptyString(s: any): boolean {
  return typeof s === "string" && s.trim().length > 0;
}
EOF

# -----------------------------------------------------------------
# 2️⃣ AI Providers
# -----------------------------------------------------------------
cat <<'EOF' > src/ai/providers/openai.ts
import fetch from "node-fetch";
const OPENAI_API = "https://api.openai.com/v1";

export async function embedText(text: string, apiKey: string) {
  const res = await fetch(`${OPENAI_API}/embeddings`, {
    method: "POST",
    headers: { "Authorization": `Bearer ${apiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify({ model: "text-embedding-3-small", input: text })
  });
  const json: any = await res.json();
  return json.data?.[0]?.embedding as number[];
}

export async function visionCaption(imageUrl: string, apiKey: string) {
  const res = await fetch(`${OPENAI_API}/chat/completions`, {
    method: "POST",
    headers: { "Authorization": `Bearer ${apiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "You are a fashion analyst." },
        { role: "user", content: [{ type: "text", text: "Describe this outfit with style tags." }, { type: "image_url", image_url: { url: imageUrl } }] as any }
      ],
      max_tokens: 150
    })
  });
  const json: any = await res.json();
  return json.choices?.[0]?.message?.content || "";
}
EOF

cat <<'EOF' > src/ai/providers/huggingface.ts
import fetch from "node-fetch";

export async function hfEmbed(text: string, apiKey: string) {
  const res = await fetch("https://api-inference.huggingface.co/pipeline/feature-extraction/sentence-transformers/all-MiniLM-L6-v2", {
    method: "POST",
    headers: { "Authorization": `Bearer ${apiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify({ inputs: text, options: { wait_for_model: true } })
  });
  const json: any = await res.json();
  return json as number[];
}
EOF

# -----------------------------------------------------------------
# 3️⃣ AI Models (embedding, vision)
# -----------------------------------------------------------------
cat <<'EOF' > src/ai/models/embeddings/embedding-model.ts
import { embedText as openAIEmbed } from "../../providers/openai.js";
import { hfEmbed } from "../../providers/huggingface.js";
import { loadConfig } from "@utils/fs.js";

export class EmbeddingModel {
  private provider: "openai" | "hf";
  constructor() {
    const cfg = loadConfig();
    this.provider = (cfg.ai.provider as any) || "openai";
  }
  async embed(text: string): Promise<number[]> {
    if (this.provider === "openai") {
      return openAIEmbed(text, process.env.OPENAI_API_KEY || "");
    } else {
      return hfEmbed(text, process.env.HF_API_KEY || "");
    }
  }
  async embedBatch(texts: string[]): Promise<number[][]> {
    return Promise.all(texts.map(t => this.embed(t)));
  }
}
EOF

cat <<'EOF' > src/ai/models/vision/vision-model.ts
import { visionCaption as openAIVision } from "../../providers/openai.js";

export class VisionModel {
  async caption(imageUrl: string): Promise<string> {
    return openAIVision(imageUrl, process.env.OPENAI_API_KEY || "");
  }
}
EOF

# -----------------------------------------------------------------
# 4️⃣ Fashion‑Genome
# -----------------------------------------------------------------
cat <<'EOF' > src/ai/fashion-genome/index.ts
export { PreferenceVector, buildFashionGenome } from "./pipeline.js";
export { fingerprintItem } from "./utils/fingerprint.js";
EOF

cat <<'EOF' > src/ai/fashion-genome/pipeline.ts
import { EmbeddingModel } from "@models/embeddings/embedding-model.js";
import { VisionModel } from "@models/vision/vision-model.js";
import { fingerprintItem } from "./utils/fingerprint.js";
import { saveGenome, loadGenome } from "./utils/storage.js";
import { loadConfig } from "@utils/fs.js";

export type MoodProfile = {
  id: string;
  name: string;
  weights: Record<string, number>;
  palette: string[];
  silhouette: string[];
};

export type PreferenceVector = {
  userId: string;
  embedding: number[];
  mood: MoodProfile;
  updatedAt: number;
};

export async function buildFashionGenome(): Promise<PreferenceVector> {
  const embedder = new EmbeddingModel();
  const vision = new VisionModel();
  const cfg = loadConfig();

  const tasteSummary = await inferFromBehavior();
  const mood = await inferMoodProfile(tasteSummary);
  const vec = await embedder.embed(JSON.stringify(mood));

  const pv: PreferenceVector = {
    userId: cfg.userId,
    embedding: vec,
    mood,
    updatedAt: Date.now(),
  };
  await saveGenome(pv);
  return pv;
}

async function inferFromBehavior(): Promise<any> {
  // Placeholder: integrate real wear‑log, item analytics, surveys, etc.
  return {
    colors: ["ivory", "black", "navy"],
    textures: ["linen", "wool"],
    silhouettes: ["relaxed", "tailored"],
    vibes: ["minimal", "classic"],
  };
}

async function inferMoodProfile(summary: any): Promise<MoodProfile> {
  return {
    id: "mood-default",
    name: "Calm Minimal",
    weights: { comfort: 0.7, formality: 0.5, colorBold: 0.3 },
    palette: summary.colors,
    silhouette: summary.silhouettes,
  };
}

export async function fingerprintItems(imageUrls: string[]) {
  const results = [];
  for (const url of imageUrls) {
    const fp = await fingerprintItem(url);
    results.push(fp);
  }
  return results;
}
EOF

cat <<'EOF' > src/ai/fashion-genome/utils/fingerprint.ts
import { VisionModel } from "@models/vision/vision-model.js";
import { EmbeddingModel } from "@models/embeddings/embedding-model.js";
import { hashString } from "@utils/hashing.js";

export type StylisticFingerprint = {
  id: string;
  colors: string[];
  silhouette: string[];
  textures: string[];
  vibe: string[];
  embedding: number[];
};

export async function fingerprintItem(imageUrl: string): Promise<StylisticFingerprint> {
  const vision = new VisionModel();
  const embedder = new EmbeddingModel();
  const caption = await vision.caption(imageUrl);
  const colors = extractTags(caption, ["color", "hue", "shade"]);
  const textures = extractTags(caption, ["fabric", "texture"]);
  const silhouette = extractTags(caption, ["fit", "cut", "silhouette", "length"]);
  const vibe = extractTags(caption, ["style", "vibe", "mood"]);
  const embedding = await embedder.embed(caption);
  return {
    id: hashString(imageUrl),
    colors,
    textures,
    silhouette,
    vibe,
    embedding,
  };
}

function extractTags(text: string, keys: string[]): string[] {
  const lower = text.toLowerCase();
  const found = new Set<string>();
  keys.forEach(k => {
    const re = new RegExp(`${k}\\s*[:=]?\\s*([a-z\\-\\s]+)`, "g");
    let m;
    while ((m = re.exec(lower))) {
      m[1].split(/[\\s,]+/).forEach(x => found.add(x.trim()));
    }
  });
  return [...found];
}
EOF

cat <<'EOF' > src/ai/fashion-genome/utils/storage.ts
import { readFile, writeFile, ensureDir } from "@utils/fs.js";
import { PreferenceVector } from "../pipeline.js";

const GENOME_PATH = "./.risn/data/genome.json";

export async function saveGenome(genome: PreferenceVector) {
  await ensureDir("./.risn/data");
  await writeFile(GENOME_PATH, JSON.stringify(genome, null, 2));
}

export async function loadGenome(): Promise<PreferenceVector | null> {
  try {
    const data = await readFile(GENOME_PATH, "utf8");
    return JSON.parse(data);
  } catch {
    return null;
  }
}
EOF

# -----------------------------------------------------------------
# 5️⃣ Body‑Twin
# -----------------------------------------------------------------
cat <<'EOF' > src/ai/body-twin/index.ts
import { estimateMeasurements } from "./estimator.js";
import { generate3DAvatar } from "./reconstructor.js";
import { measurementsToFit } from "./measurements.js";
import { applyTryOn } from "./tryon.js";

export const BodyTwin = {
  estimateMeasurements,
  generate3DAvatar,
  measurementsToFit,
  applyTryOn,
};
EOF

cat <<'EOF' > src/ai/body-twin/estimator.ts
export type BodyEstimate = {
  heightCm: number;
  chestCm: number;
  waistCm: number;
  hipCm: number;
  inseamCm: number;
  shouldersCm: number;
};

export async function estimateMeasurements(images: string[]): Promise<BodyEstimate> {
  // Placeholder – integrate MediaPipe/TensorFlow in production
  const est: BodyEstimate = {
    heightCm: 175 + Math.floor(Math.random() * 10),
    chestCm: 90 + Math.floor(Math.random() * 10),
    waistCm: 75 + Math.floor(Math.random() * 10),
    hipCm: 95 + Math.floor(Math.random() * 10),
    inseamCm: 75 + Math.floor(Math.random() * 5),
    shouldersCm: 45 + Math.floor(Math.random() * 5),
  };
  return est;
}
EOF

cat <<'EOF' > src/ai/body-twin/reconstructor.ts
export type BodyTwin3D = {
  id: string;
  meshUrl?: string;
  skeletonUrl?: string;
};

export async function generate3DAvatar(images: string[]): Promise<BodyTwin3D> {
  // Stub: call external 3‑D recon service
  return {
    id: "twin-" + Date.now(),
    meshUrl: undefined,
    skeletonUrl: undefined
  };
}
EOF

cat <<'EOF' > src/ai/body-twin/measurements.ts
import { BodyEstimate } from "./estimator.js";

export type FitPrediction = {
  itemId: string;
  fit: "tight" | "fitted" | "regular" | "relaxed" | "oversized";
  confidence: number;
};

export function measurementsToFit(est: BodyEstimate, itemSpecs: any): FitPrediction {
  const diff = (a: number, b: number) => Math.abs(a - b);
  const chestFit = diff(est.chestCm, itemSpecs.chestCm ?? est.chestCm);
  const waistFit = diff(est.waistCm, itemSpecs.waistCm ?? est.waistCm);
  const avg = (chestFit + waistFit) / 2;
  let fit: FitPrediction["fit"] = "regular";
  if (avg < 2) fit = "tight";
  else if (avg < 4) fit = "fitted";
  else if (avg < 7) fit = "regular";
  else if (avg < 10) fit = "relaxed";
  else fit = "oversized";
  return { itemId: itemSpecs.id ?? "item", fit, confidence: Math.max(0.5, 1 - avg / 15) };
}
EOF

cat <<'EOF' > src/ai/body-twin/tryon.ts
export async function applyTryOn(itemId: string, images: string[]) {
  // Stub: send to virtual‑try‑on service
  return { itemId, status: "ok", compositeUrl: undefined };
}
EOF

# -----------------------------------------------------------------
# 6️⃣ Emotional‑Weather Dressing
# -----------------------------------------------------------------
cat <<'EOF' > src/ai/emotional-weather/index.ts
export { EmotionalWeather } from "./analyzer.js";
export { recommendBundle } from "./recommender.js";
EOF

cat <<'EOF' > src/ai/emotional-weather/analyzer.ts
import { EmbeddingModel } from "@models/embeddings/embedding-model.js";
import { loadConfig } from "@utils/fs.js";

export type Mood = {
  id: string;
  name: string;
  valence: number;
  arousal: number;
  palette: string[];
  silhouette: string[];
  occasion: string;
};

export const EmotionalWeather = {
  async analyzeText(text: string): Promise<Mood> {
    const emb = new EmbeddingModel();
    const vec = await emb.embed(text);
    const cfg = loadConfig();
    const val = (vec.slice(0, 10).reduce((a, b) => a + b, 0) % 2 === 0) ? 0.6 : 0.4;
    const ar = (vec.slice(10, 20).reduce((a, b) => a + b, 0) % 2 === 0) ? 0.5 : 0.7;
    const palette = val > 0.5 ? ["ivory", "mint", "sky"] : ["charcoal", "wine", "ink"];
    const silhouette = ar > 0.6 ? ["relaxed"] : ["tailored"];
    return { id: "mood-" + Date.now(), name: "Current Mood", valence: val, arousal: ar, palette, silhouette, occasion: "daily" };
  },
  async analyzeVoice(transcript: string): Promise<Mood> {
    return EmotionalWeather.analyzeText(transcript);
  },
};
EOF

cat <<'EOF' > src/ai/emotional-weather/recommender.ts
import { CapsuleBuilder } from "@integrations/store-system/builder.js";

export async function recommendBundle(mood: any) {
  const capsule = CapsuleBuilder.fromMood(mood, mood.palette);
  capsule.items = ["top-1", "bottom-1", "shoe-1", "acc-1"];
  return capsule;
}
EOF

# -----------------------------------------------------------------
# 7️⃣ Event‑Prediction Engine
# -----------------------------------------------------------------
cat <<'EOF' > src/ai/event-prediction/index.ts
export { EventPrediction } from "./prebuilt-capsules.js";
EOF

cat <<'EOF' > src/ai/event-prediction/prebuilt-capsules.ts
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
EOF

cat <<'EOF' > src/ai/event-prediction/scheduler.ts
export class CapsuleScheduler {}
EOF

# -----------------------------------------------------------------
# 8️⃣ Closet‑Telemetry
# -----------------------------------------------------------------
cat <<'EOF' > src/ai/closet-telemetry/index.ts
export { ClosetTelemetry } from "./mapper.js";
export { OutfitCurator } from "./generator.js";
EOF

cat <<'EOF' > src/ai/closet-telemetry/mapper.ts
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
EOF

cat <<'EOF' > src/ai/closet-telemetry/generator.ts
import { ClosetItem } from "./mapper.js";

export class OutfitCurator {
  async curate(horizon: "week" | "month") {
    // Naive curator – replace with AI‑powered recommendation
    return [
      { id: "outfit-1", name: "Smart Office", items: ["top-1", "bottom-1", "shoe-1"] },
      { id: "outfit-2", name: "Casual Errands", items: ["top-2", "bottom-2"] }
    ];
  }
  async generateSmartOutfits() {
    return this.curate("week");
  }
}
EOF

# -----------------------------------------------------------------
# 9️⃣ Vector Store
# -----------------------------------------------------------------
cat <<'EOF' > src/ai/vectors/index.ts
export { VectorIndex } from "./indexer.js";
EOF

cat <<'EOF' > src/ai/vectors/indexer.ts
import { EmbeddingModel } from "@models/embeddings/embedding-model.js";
import { VectorStore } from "./store/memory.js";

export class VectorIndex {
  store = new VectorStore();
  embedder = new EmbeddingModel();
  upsert(id: string, vec: number[]) { this.store.upsert(id, vec); }
  async reindexAll() { /* TODO: re‑index from closet */ }
  async query(text: string) {
    const vec = await this.embedder.embed(text);
    return this.store.similarity(vec, 10);
  }
}
EOF

cat <<'EOF' > src/ai/vectors/store/memory.ts
export class VectorStore {
  items = new Map<string, number[]>();
  upsert(id: string, vec: number[]) { this.items.set(id, vec); }
  get(id: string) { return this.items.get(id); }
  similarity(q: number[], k = 10) {
    const sim = (a: number[], b: number[]) => cosine(a, b);
    const arr = [...this.items.entries()].map(([id, vec]) => ({ id, score: sim(q, vec) }));
    arr.sort((a, b) => b.score - a.score);
    return arr.slice(0, k);
  }
}
function cosine(a: number[], b: number[]) {
  let dot = 0, na = 0, nb = 0;
  for (let i = 0; i < Math.min(a.length, b.length); i++) {
    dot += a[i] * b[i]; na += a[i] * a[i]; nb += b[i] * b[i];
  }
  return dot / (Math.sqrt(na) * Math.sqrt(nb) + 1e-8);
}
EOF

# -----------------------------------------------------------------
# 🔟 Integrations (Store System & Automation Engine)
# -----------------------------------------------------------------
cat <<'EOF' > src/integrations/store-system/index.ts
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
EOF

cat <<'EOF' > src/integrations/store-system/builder.ts
export type Capsule = {
  id: string;
  name: string;
  occasion: string;
  items: string[];
  palette: string[];
  silhouette: string[];
  season?: string;
};

export class CapsuleBuilder {
  static fromMood(mood: any, palette: string[]): Capsule {
    return {
      id: "mood-" + mood.id,
      name: `${mood.name} Capsule`,
      occasion: mood.occasion || "general",
      items: [],
      palette,
      silhouette: mood.silhouette || ["relaxed"],
    };
  }
  static fromEvent(event: any): Capsule {
    return {
      id: "event-" + event.id,
      name: event.title + " Capsule",
      occasion: event.type,
      items: [],
      palette: event.palette || [],
      silhouette: event.silhouette || [],
      season: event.season
    };
  }
}
EOF

cat <<'EOF' > src/integrations/store-system/events.ts
export const StoreEvents = {
  MERCH_UPDATE: "merch.update",
  ITEM_DEMAND: "item.demand",
  CAPSULE_PUBLISHED: "capsule.published",
};
EOF

cat <<'EOF' > src/integrations/automation-engine/index.ts
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
EOF

cat <<'EOF' > src/integrations/automation-engine/workflows.ts
import { CapsuleBuilder } from "@integrations/store-system/builder.js";

export type WorkflowContext = {
  userId: string;
  event?: any;
  mood?: any;
  closet?: any;
};

export const OutfitWorkflow = {
  async run(ctx: WorkflowContext) {
    if (ctx.mood) return CapsuleBuilder.fromMood(ctx.mood, ctx.mood.palette);
    if (ctx.event) return CapsuleBuilder.fromEvent(ctx.event);
    throw new Error("No workflow context supplied");
  }
};
EOF

cat <<'EOF' > src/integrations/automation-engine/event-bus.ts
export type EventBusMessage = {
  topic: string;
  data: any;
};

export class EventBus {
  publish(topic: string, data: any) {
    // Stub – replace with Redis/Kafka in production
  }
}
EOF

# -----------------------------------------------------------------
# 1️⃣1️⃣ Pipelines & Workers
# -----------------------------------------------------------------
cat <<'EOF' > src/pipelines/jobs.ts
export const JobTypes = {
  FASHION_GENOME_BUILD: "fashion.genome.build",
  BODY_TWIN_ESTIMATE: "body.twin.estimate",
  CLOSET_MAP: "closet.map",
  EVENT_SCAN: "events.scan",
};
EOF

cat <<'EOF' > src/pipelines/registry.ts
import { JobTypes } from "./jobs.js";
import { buildFashionGenome } from "@ai/fashion-genome/pipeline.js";

export const PipelineRegistry = {
  [JobTypes.FASHION_GENOME_BUILD]: async () => await buildFashionGenome(),
};
EOF

cat <<'EOF' > src/workers/queue.ts
type Job = { id: string; type: string; payload: any; };
export class Queue {
  jobs: Job[] = [];
  enqueue(job: Job) { this.jobs.push(job); }
  dequeue(): Job | undefined { return this.jobs.shift(); }
}
EOF

cat <<'EOF' > src/workers/workers.ts
import { Queue } from "./queue.js";
export const WorkerPool = {
  queues: { default: new Queue() },
  start() { console.log("Worker pool started"); }
};
EOF

# -----------------------------------------------------------------
# 1️⃣2️⃣ Middleware
# -----------------------------------------------------------------
cat <<'EOF' > src/middleware/auth.ts
import { loadConfig } from "@utils/fs.js";

export function apiKeyAuth(req: any, res: any, next: any) {
  const key = req.headers["x-api-key"];
  const cfg = loadConfig();
  if (key === cfg.store.apiKey) return next();
  res.status(401).json({ error: "unauthorized" });
}
EOF

cat <<'EOF' > src/middleware/rate-limit.ts
const buckets = new Map<string, { count: number; reset: number }>();
export function rateLimit(req: any, res: any, next: any) {
  const ip = req.ip || "anon";
  const now = Date.now();
  const b = buckets.get(ip) || { count: 0, reset: now + 60000 };
  if (now > b.reset) { b.count = 0; b.reset = now + 60000; }
  b.count++;
  buckets.set(ip, b);
  if (b.count > 100) return res.status(429).json({ error: "too many requests" });
  next();
}
EOF

cat <<'EOF' > src/middleware/validation.ts
export function validate(schema: any) {
  return (req: any, res: any, next: any) => {
    // tiny validator stub – replace with AJV/Zod if needed
    next();
  };
}
EOF

# -----------------------------------------------------------------
# 1️⃣3️⃣ Plugin System
# -----------------------------------------------------------------
cat <<'EOF' > src/plugins/types.ts
export type RISNPlugin = {
  name: string;
  version: string;
  init: () => Promise<void> | void;
  hooks: Record<string, Function>;
};
EOF

cat <<'EOF' > src/plugins/loader.ts
import fs from "fs";
import path from "path";
import { RISNPlugin } from "./types.js";
import { loadConfig } from "@utils/fs.js";

export async function loadPlugins(): Promise<RISNPlugin[]> {
  const cfg = loadConfig();
  const dir = path.join(process.cwd(), ".risn", "plugins");
  if (!fs.existsSync(dir)) return [];
  const files = fs.readdirSync(dir).filter(f => f.endsWith(".so") || f.endsWith(".js"));
  const plugins: RISNPlugin[] = [];
  for (const f of files) {
    const mod = await import(path.join("file://", dir, f));
    const plugin = (mod.default || mod) as RISNPlugin;
    plugins.push(plugin);
  }
  return plugins;
}
EOF

cat <<'EOF' > src/plugins/samples/plugin-sample.ts
import { RISNPlugin } from "../types.js";

const plugin: RISNPlugin = {
  name: "sample-plugin",
  version: "1.0.0",
  async init() { console.log("Sample plugin initialized"); },
  hooks: {
    "genome.build.post": async (payload: any) => console.log("Genome build post‑hook", payload)
  }
};
export default plugin;
EOF

# -----------------------------------------------------------------
# 1️⃣4️⃣ API Layer (Express)
# -----------------------------------------------------------------
cat <<'EOF' > src/api/server.ts
import express from "express";
import { apiKeyAuth } from "@middleware/auth.js";
import { rateLimit } from "@middleware/rate-limit.js";
import routes from "./routes/index.js";

export function createAPIServer() {
  const app = express();
  app.use(express.json({ limit: "10mb" }));
  app.use(rateLimit);
  app.use(apiKeyAuth);
  app.use("/api", routes);
  return app;
}
EOF

cat <<'EOF' > src/api/routes/index.ts
import { Router } from "express";
import genome from "./fashionGenome.js";
import closet from "./closet.js";
import tryOn from "./tryOn.js";
import mood from "./mood.js";
import events from "./events.js";
import outfits from "./outfits.js";
import telemetry from "./telemetry.js";
import vectors from "./vectors.js";
import health from "./health.js";

const router = Router();
router.use("/genome", genome);
router.use("/closet", closet);
router.use("/tryon", tryOn);
router.use("/mood", mood);
router.use("/events", events);
router.use("/outfits", outfits);
router.use("/telemetry", telemetry);
router.use("/vectors", vectors);
router.use("/health", health);

export default router;
EOF

cat <<'EOF' > src/api/routes/fashionGenome.ts
import { Router } from "express";
import { buildFashionGenome } from "@ai/fashion-genome/pipeline.js";
const router = Router();
router.post("/build", async (req, res) => {
  const result = await buildFashionGenome();
  res.json(result);
});
export default router;
EOF

cat <<'EOF' > src/api/routes/closet.ts
import { Router } from "express";
import { ClosetTelemetry } from "@ai/closet-telemetry/mapper.js";
const router = Router();
router.get("/map", async (req, res) => {
  const ct = new ClosetTelemetry();
  const out = await ct.mapFromFile();
  res.json(out);
});
export default router;
EOF

cat <<'EOF' > src/api/routes/tryOn.ts
import { Router } from "express";
import { BodyTwin } from "@ai/body-twin/index.js";
const router = Router();
router.post("/estimate", async (req, res) => {
  res.json(await BodyTwin.estimateMeasurements(req.body.images || []));
});
router.post("/generate", async (req, res) => {
  res.json(await BodyTwin.generate3DAvatar(req.body.images || []));
});
router.post("/apply", async (req, res) => {
  res.json(await BodyTwin.applyTryOn(req.body.itemId, req.body.images || []));
});
export default router;
EOF

cat <<'EOF' > src/api/routes/mood.ts
import { Router } from "express";
import { EmotionalWeather } from "@ai/emotional-weather/analyzer.js";
const router = Router();
router.post("/", async (req, res) => {
  const mood = await EmotionalWeather.analyzeText(req.body.text || "");
  res.json(mood);
});
export default router;
EOF

cat <<'EOF' > src/api/routes/events.ts
import { Router } from "express";
import { EventPrediction } from "@ai/event-prediction/prebuilt-capsules.js";
const router = Router();
router.post("/scan", async (req, res) => {
  res.json(await EventPrediction.scanCalendar(req.body.icsPath));
});
router.post("/notify", async (req, res) => {
  res.json(await EventPrediction.notifyStore());
});
export default router;
EOF

cat <<'EOF' > src/api/routes/outfits.ts
import { Router } from "express";
import { OutfitCurator } from "@ai/closet-telemetry/generator.js";
const router = Router();
router.post("/", async (req, res) => {
  const curator = new OutfitCurator();
  res.json(await curator.curate("week"));
});
export default router;
EOF

cat <<'EOF' > src/api/routes/telemetry.ts
import { Router } from "express";
const router = Router();
router.post("/enable", (req, res) => res.json({ enabled: true }));
export default router;
EOF

cat <<'EOF' > src/api/routes/vectors.ts
import { Router } from "express";
import { VectorIndex } from "@ai/vectors/indexer.js";
const router = Router();
router.post("/query", async (req, res) => {
  const vi = new VectorIndex();
  const result = await vi.query(req.body.text || "");
  res.json(result);
});
export default router;
EOF

cat <<'EOF' > src/api/routes/health.ts
import { Router } from "express";
const router = Router();
router.get("/", (req, res) => res.json({ ok: true }));
export default router;
EOF

# -----------------------------------------------------------------
# 1️⃣5️⃣ Updated Package.json
# -----------------------------------------------------------------
cat <<'EOF' > package.json
{
  "name": "risn-eco-cli",
  "version": "2.0.0",
  "description": "RISN ECO CLI – Next‑Gen Fashion Intelligence Engine",
  "type": "module",
  "main": "src/index.ts",
  "bin": {
    "risn": "src/index.ts"
  },
  "scripts": {
    "dev": "tsx --watch src/index.ts --help",
    "build": "tsc -p tsconfig.json",
    "start": "node dist/index.js",
    "test": "jest"
  },
  "dependencies": {
    "yargs": "^17.7.2",
    "axios": "^1.7.2",
    "node-ical": "^0.16.0",
    "dotenv": "^16.4.5",
    "uuid": "^9.0.1",
    "level": "^8.0.0",
    "node-fetch": "^3.3.2",
    "form-data": "^4.0.0",
    "dayjs": "^1.11.13",
    "express": "^4.19.2",
    "cors": "^2.8.5"
  },
  "optionalDependencies": {
    "@mediapipe/pose": "^0.5.1719429404",
    "sharp": "^0.33.4",
    "@tensorflow/tfjs-node": "^4.18.0"
  },
  "devDependencies": {
    "tsx": "^4.19.1",
    "typescript": "^5.5.4",
    "@types/node": "^22.5.0",
    "@types/yargs": "^17.0.33",
    "jest": "^29.7.0",
    "ts-jest": "^29.2.5"
  }
}
EOF

# -----------------------------------------------------------------
# 1️⃣6️⃣ Updated tsconfig.json (path mapping)
# -----------------------------------------------------------------
cat <<'EOF' > tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM"],
    "module": "ES2022",
    "moduleResolution": "Node",
    "esModuleInterop": true,
    "outDir": "dist",
    "rootDir": ".",
    "strict": true,
    "skipLibCheck": true,
    "resolveJsonModule": true,
    "baseUrl": ".",
    "paths": {
      "@ai/*": ["src/ai/*"],
      "@core/*": ["src/core/*"],
      "@store/*": ["src/integrations/store-system/*"],
      "@automation/*": ["src/integrations/automation-engine/*"],
      "@workers/*": ["src/workers/*"],
      "@pipelines/*": ["src/pipelines/*"],
      "@middleware/*": ["src/middleware/*"],
      "@api/*": ["src/api/*"],
      "@plugins/*": ["src/plugins/*"],
      "@data/*": ["data/*"],
      "@utils/*": ["src/utils/*"],
      "@integrations/*": ["src/integrations/*"],
      "@vectors/*": ["src/ai/vectors/*"],
      "@models/*": ["src/ai/models/*"]
    }
  },
  "include": ["src/**/*", "data/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

# -----------------------------------------------------------------
# 1️⃣7️⃣ Updated risn.config.js (Node‑based config)
# -----------------------------------------------------------------
cat <<'EOF' > risn.config.js
import dotenv from "dotenv";
dotenv.config();

export const RISN_CONFIG = {
  userId: process.env.RISN_USER_ID || "demo-user",
  dataDir: process.env.RISN_DATA_DIR || "./.risn/data",
  vectorsDir: process.env.RISN_VECTORS_DIR || "./.risn/vectors",
  logsDir: process.env.RISN_LOGS_DIR || "./.risn/logs",

  ai: {
    provider: process.env.RISN_AI_PROVIDER || "openai",
    embeddingModel: process.env.RISN_EMBEDDING_MODEL || "text-embedding-3-small",
    visionModel: process.env.RISN_VISION_MODEL || "gpt-4o-mini",
  },

  store: {
    baseUrl: process.env.RISN_STORE_BASE_URL || "http://localhost:4000",
    apiKey: process.env.RISN_STORE_API_KEY || "store-dev-key",
  },

  automation: {
    eventBus: process.env.RISN_EVENT_BUS || "memory",
    queue: process.env.RISN_QUEUE || "memory",
  },
};
EOF

# -----------------------------------------------------------------
# 1️⃣8️⃣ Existing CLI entry‑point (can stay unchanged – just import API if needed)
# -----------------------------------------------------------------
# No changes required – the original src/index.ts (or bin entry) will continue to work.

# -----------------------------------------------------------------
# 1️⃣9️⃣ Install dependencies after upgrade
# -----------------------------------------------------------------
npm install

# -----------------------------------------------------------------
# 2️⃣0️⃣ Finish
# -----------------------------------------------------------------
echo "✅ Upgrade complete – you can now run the CLI (npm run dev) and the API (node dist/api/server.js)."
