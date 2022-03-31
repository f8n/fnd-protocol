import { BigInt, ethereum } from "@graphprotocol/graph-ts";

export function getLogId(event: ethereum.Event): string {
  return event.transaction.hash.toHex() + "-" + event.logIndex.toString();
}

export function getEventId(event: ethereum.Event, eventType: string): string {
  return getLogId(event) + "-" + eventType;
}

export function getPreviousEventId(event: ethereum.Event, eventType: string, logIndex: BigInt): string {
  return event.transaction.hash.toHex() + "-" + logIndex.toString() + "-" + eventType;
}
