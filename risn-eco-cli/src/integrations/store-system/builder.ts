export type Capsule = {
  id: string;
  name: string;
  occasion: string;
  items: string[];
  palette: string[];
  silhouette: string[];
  season?: string;
};

export class CapsuleBuilder {
  static fromMood(mood: any, palette: string[]): Capsule {
    return {
      id: "mood-" + mood.id,
      name: `${mood.name} Capsule`,
      occasion: mood.occasion || "general",
      items: [],
      palette,
      silhouette: mood.silhouette || ["relaxed"],
    };
  }
  static fromEvent(event: any): Capsule {
    return {
      id: "event-" + event.id,
      name: event.title + " Capsule",
      occasion: event.type,
      items: [],
      palette: event.palette || [],
      silhouette: event.silhouette || [],
      season: event.season
    };
  }
}
