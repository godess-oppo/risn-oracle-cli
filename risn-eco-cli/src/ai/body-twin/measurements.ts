import { BodyEstimate } from "./estimator.js";

export type FitPrediction = {
  itemId: string;
  fit: "tight" | "fitted" | "regular" | "relaxed" | "oversized";
  confidence: number;
};

export function measurementsToFit(est: BodyEstimate, itemSpecs: any): FitPrediction {
  const diff = (a: number, b: number) => Math.abs(a - b);
  const chestFit = diff(est.chestCm, itemSpecs.chestCm ?? est.chestCm);
  const waistFit = diff(est.waistCm, itemSpecs.waistCm ?? est.waistCm);
  const avg = (chestFit + waistFit) / 2;
  let fit: FitPrediction["fit"] = "regular";
  if (avg < 2) fit = "tight";
  else if (avg < 4) fit = "fitted";
  else if (avg < 7) fit = "regular";
  else if (avg < 10) fit = "relaxed";
  else fit = "oversized";
  return { itemId: itemSpecs.id ?? "item", fit, confidence: Math.max(0.5, 1 - avg / 15) };
}
