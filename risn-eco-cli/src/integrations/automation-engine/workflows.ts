import { CapsuleBuilder } from "@integrations/store-system/builder.js";

export type WorkflowContext = {
  userId: string;
  event?: any;
  mood?: any;
  closet?: any;
};

export const OutfitWorkflow = {
  async run(ctx: WorkflowContext) {
    if (ctx.mood) return CapsuleBuilder.fromMood(ctx.mood, ctx.mood.palette);
    if (ctx.event) return CapsuleBuilder.fromEvent(ctx.event);
    throw new Error("No workflow context supplied");
  }
};
