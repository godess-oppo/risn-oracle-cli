import dotenv from "dotenv";
dotenv.config();

export const RISN_CONFIG = {
  userId: process.env.RISN_USER_ID || "demo-user",
  dataDir: process.env.RISN_DATA_DIR || "./.risn/data",
  vectorsDir: process.env.RISN_VECTORS_DIR || "./.risn/vectors",
  logsDir: process.env.RISN_LOGS_DIR || "./.risn/logs",

  ai: {
    provider: process.env.RISN_AI_PROVIDER || "openai",
    embeddingModel: process.env.RISN_EMBEDDING_MODEL || "text-embedding-3-small",
    visionModel: process.env.RISN_VISION_MODEL || "gpt-4o-mini",
  },

  store: {
    baseUrl: process.env.RISN_STORE_BASE_URL || "http://localhost:4000",
    apiKey: process.env.RISN_STORE_API_KEY || "store-dev-key",
  },

  automation: {
    eventBus: process.env.RISN_EVENT_BUS || "memory",
    queue: process.env.RISN_QUEUE || "memory",
  },
};
