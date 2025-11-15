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
