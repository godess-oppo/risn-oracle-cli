const buckets = new Map<string, { count: number; reset: number }>();
export function rateLimit(req: any, res: any, next: any) {
  const ip = req.ip || "anon";
  const now = Date.now();
  const b = buckets.get(ip) || { count: 0, reset: now + 60000 };
  if (now > b.reset) { b.count = 0; b.reset = now + 60000; }
  b.count++;
  buckets.set(ip, b);
  if (b.count > 100) return res.status(429).json({ error: "too many requests" });
  next();
}
