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
