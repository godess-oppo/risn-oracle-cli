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
