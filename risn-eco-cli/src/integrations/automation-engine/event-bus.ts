export type EventBusMessage = {
  topic: string;
  data: any;
};

export class EventBus {
  publish(topic: string, data: any) {
    // Stub – replace with Redis/Kafka in production
  }
}
