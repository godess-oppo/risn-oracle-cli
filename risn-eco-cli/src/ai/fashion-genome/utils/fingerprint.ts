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
