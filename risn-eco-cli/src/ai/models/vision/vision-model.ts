import { visionCaption as openAIVision } from "../../providers/openai.js";

export class VisionModel {
  async caption(imageUrl: string): Promise<string> {
    return openAIVision(imageUrl, process.env.OPENAI_API_KEY || "");
  }
}
