import { loadConfig } from "@utils/fs.js";

export function apiKeyAuth(req: any, res: any, next: any) {
  const key = req.headers["x-api-key"];
  const cfg = loadConfig();
  if (key === cfg.store.apiKey) return next();
  res.status(401).json({ error: "unauthorized" });
}
