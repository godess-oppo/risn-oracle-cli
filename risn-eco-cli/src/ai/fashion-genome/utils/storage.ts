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
