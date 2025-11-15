import { estimateMeasurements } from "./estimator.js";
import { generate3DAvatar } from "./reconstructor.js";
import { measurementsToFit } from "./measurements.js";
import { applyTryOn } from "./tryon.js";

export const BodyTwin = {
  estimateMeasurements,
  generate3DAvatar,
  measurementsToFit,
  applyTryOn,
};
