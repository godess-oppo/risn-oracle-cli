import fs from "fs";
import path from "path";
import { RISNPlugin } from "./types.js";
import { loadConfig } from "@utils/fs.js";

export async function loadPlugins(): Promise<RISNPlugin[]> {
  const cfg = loadConfig();
  const dir = path.join(process.cwd(), ".risn", "plugins");
  if (!fs.existsSync(dir)) return [];
  const files = fs.readdirSync(dir).filter(f => f.endsWith(".so") || f.endsWith(".js"));
  const plugins: RISNPlugin[] = [];
  for (const f of files) {
    const mod = await import(path.join("file://", dir, f));
    const plugin = (mod.default || mod) as RISNPlugin;
    plugins.push(plugin);
  }
  return plugins;
}
