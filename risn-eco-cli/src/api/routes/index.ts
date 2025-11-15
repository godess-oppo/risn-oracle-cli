import { Router } from "express";
import genome from "./fashionGenome.js";
import closet from "./closet.js";
import tryOn from "./tryOn.js";
import mood from "./mood.js";
import events from "./events.js";
import outfits from "./outfits.js";
import telemetry from "./telemetry.js";
import vectors from "./vectors.js";
import health from "./health.js";

const router = Router();
router.use("/genome", genome);
router.use("/closet", closet);
router.use("/tryon", tryOn);
router.use("/mood", mood);
router.use("/events", events);
router.use("/outfits", outfits);
router.use("/telemetry", telemetry);
router.use("/vectors", vectors);
router.use("/health", health);

export default router;
