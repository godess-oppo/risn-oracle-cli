import { RISNPlugin } from "../types.js";

const plugin: RISNPlugin = {
  name: "sample-plugin",
  version: "1.0.0",
  async init() { console.log("Sample plugin initialized"); },
  hooks: {
    "genome.build.post": async (payload: any) => console.log("Genome build post‑hook", payload)
  }
};
export default plugin;
