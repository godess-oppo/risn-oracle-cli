import { CapsuleBuilder } from "@integrations/store-system/builder.js";

export async function recommendBundle(mood: any) {
  const capsule = CapsuleBuilder.fromMood(mood, mood.palette);
  capsule.items = ["top-1", "bottom-1", "shoe-1", "acc-1"];
  return capsule;
}
