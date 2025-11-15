import { Router } from "express";
import { BodyTwin } from "@ai/body-twin/index.js";
const router = Router();
router.post("/estimate", async (req, res) => {
  res.json(await BodyTwin.estimateMeasurements(req.body.images || []));
});
router.post("/generate", async (req, res) => {
  res.json(await BodyTwin.generate3DAvatar(req.body.images || []));
});
router.post("/apply", async (req, res) => {
  res.json(await BodyTwin.applyTryOn(req.body.itemId, req.body.images || []));
});
export default router;
