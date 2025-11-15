import { Router } from "express";
import { buildFashionGenome } from "@ai/fashion-genome/pipeline.js";
const router = Router();
router.post("/build", async (req, res) => {
  const result = await buildFashionGenome();
  res.json(result);
});
export default router;
