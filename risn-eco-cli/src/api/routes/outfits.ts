import { Router } from "express";
import { OutfitCurator } from "@ai/closet-telemetry/generator.js";
const router = Router();
router.post("/", async (req, res) => {
  const curator = new OutfitCurator();
  res.json(await curator.curate("week"));
});
export default router;
