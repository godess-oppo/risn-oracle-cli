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
