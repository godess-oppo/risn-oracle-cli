import express from "express";
import { apiKeyAuth } from "@middleware/auth.js";
import { rateLimit } from "@middleware/rate-limit.js";
import routes from "./routes/index.js";

export function createAPIServer() {
  const app = express();
  app.use(express.json({ limit: "10mb" }));
  app.use(rateLimit);
  app.use(apiKeyAuth);
  app.use("/api", routes);
  return app;
}
