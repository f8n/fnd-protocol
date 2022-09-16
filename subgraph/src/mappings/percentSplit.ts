import {
  PercentSplitCreated as PercentSplitCreatedEvent,
  PercentSplitShare as PercentSplitShareEvent,
} from "../../generated/PercentSplit/PercentSplitContract";
import { PercentSplit, PercentSplitShare } from "../../generated/schema";
import { PercentSplit as PercentSplitTemplate } from "../../generated/templates";
import { loadOrCreateAccount } from "../shared/accounts";
import { ONE_BIG_INT, ZERO_BIG_INT } from "../shared/constants";
import { toPercent } from "../shared/conversions";

export function handlePercentSplitCreated(event: PercentSplitCreatedEvent): void {
  let splitEntity = new PercentSplit(event.params.contractAddress.toHex());
  splitEntity.shareCount = ZERO_BIG_INT;
  splitEntity.dateCreated = event.block.timestamp;
  splitEntity.save();
  PercentSplitTemplate.create(event.params.contractAddress);
}

export function handlePercentSplitShare(event: PercentSplitShareEvent): void {
  let splitEntity = PercentSplit.load(event.address.toHex());
  if (!splitEntity) {
    return;
  }

  let shareEntity = new PercentSplitShare(event.address.toHex() + "-" + event.logIndex.toString());
  shareEntity.split = event.address.toHex();
  shareEntity.account = loadOrCreateAccount(event.params.recipient).id;
  shareEntity.shareInPercent = toPercent(event.params.percentInBasisPoints);
  shareEntity.indexOfShare = splitEntity.shareCount;
  shareEntity.save();

  splitEntity.shareCount = splitEntity.shareCount.plus(ONE_BIG_INT);
  splitEntity.save();
}
