import { Router } from "express";
import { EventPrediction } from "@ai/event-prediction/prebuilt-capsules.js";
const router = Router();
router.post("/scan", async (req, res) => {
  res.json(await EventPrediction.scanCalendar(req.body.icsPath));
});
router.post("/notify", async (req, res) => {
  res.json(await EventPrediction.notifyStore());
});
export default router;
