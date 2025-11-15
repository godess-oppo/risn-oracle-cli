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
