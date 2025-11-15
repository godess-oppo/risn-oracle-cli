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
