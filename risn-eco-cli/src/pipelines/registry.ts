import { JobTypes } from "./jobs.js";
import { buildFashionGenome } from "@ai/fashion-genome/pipeline.js";

export const PipelineRegistry = {
  [JobTypes.FASHION_GENOME_BUILD]: async () => await buildFashionGenome(),
};
