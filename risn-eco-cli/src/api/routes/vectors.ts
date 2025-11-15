import { Router } from "express";
import { VectorIndex } from "@ai/vectors/indexer.js";
const router = Router();
router.post("/query", async (req, res) => {
  const vi = new VectorIndex();
  const result = await vi.query(req.body.text || "");
  res.json(result);
});
export default router;
