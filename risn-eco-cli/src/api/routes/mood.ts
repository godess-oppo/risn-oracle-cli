import { Router } from "express";
import { EmotionalWeather } from "@ai/emotional-weather/analyzer.js";
const router = Router();
router.post("/", async (req, res) => {
  const mood = await EmotionalWeather.analyzeText(req.body.text || "");
  res.json(mood);
});
export default router;
