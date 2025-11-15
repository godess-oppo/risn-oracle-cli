import { Router } from "express";
import { ClosetTelemetry } from "@ai/closet-telemetry/mapper.js";
const router = Router();
router.get("/map", async (req, res) => {
  const ct = new ClosetTelemetry();
  const out = await ct.mapFromFile();
  res.json(out);
});
export default router;
