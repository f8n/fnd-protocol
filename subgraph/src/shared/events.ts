import { BigDecimal, BigInt, Bytes, ethereum, store } from "@graphprotocol/graph-ts";

import {
  Account,
  Nft,
  NftHistory,
  NftMarketAuction,
  NftMarketBuyNow,
  NftMarketOffer,
  PrivateSale,
} from "../../generated/schema";
import { loadOrCreateAccount } from "./accounts";
import { ONE_BIG_INT, ZERO_BIG_INT } from "./constants";
import { getEventId, getPreviousEventId } from "./ids";

export function recordNftEvent(
  event: ethereum.Event,
  nft: Nft,
  eventType: string,
  actorAccount: Account,
  auction: NftMarketAuction | null = null,
  marketplace: string | null = null,
  amountInETH: BigDecimal | null = null,
  nftRecipient: Account | null = null,
  dateOverride: BigInt | null = null,
  amountInTokens: BigInt | null = null,
  tokenAddress: Bytes | null = null,
  privateSale: PrivateSale | null = null,
  offer: NftMarketOffer | null = null,
  buyNow: NftMarketBuyNow | null = null,
): void {
  let historicalEvent = new NftHistory(getEventId(event, eventType));
  historicalEvent.nft = nft.id;
  historicalEvent.event = eventType;
  if (auction) {
    historicalEvent.auction = auction.id;
  }
  if (dateOverride) {
    historicalEvent.date = dateOverride as BigInt;
  } else {
    historicalEvent.date = event.block.timestamp;
  }
  historicalEvent.contractAddress = event.address;
  historicalEvent.transactionHash = event.transaction.hash;
  historicalEvent.actorAccount = actorAccount.id;
  historicalEvent.txOrigin = loadOrCreateAccount(event.transaction.from).id;
  if (nftRecipient) {
    historicalEvent.nftRecipient = nftRecipient.id;
  }
  historicalEvent.marketplace = marketplace;
  historicalEvent.amountInETH = amountInETH;
  historicalEvent.amountInTokens = amountInTokens;
  historicalEvent.tokenAddress = tokenAddress;
  if (privateSale) {
    historicalEvent.privateSale = privateSale.id;
  }
  if (offer) {
    historicalEvent.offer = offer.id;
  }
  if (buyNow) {
    historicalEvent.buyNow = buyNow.id;
  }
  historicalEvent.save();
}

export function removePreviousTransferEvent(event: ethereum.Event): void {
  // There may be multiple logs that occurred since the last transfer event
  for (let i = event.logIndex.minus(ONE_BIG_INT); i.ge(ZERO_BIG_INT); i = i.minus(ONE_BIG_INT)) {
    let previousEvent = NftHistory.load(getPreviousEventId(event, "Transferred", i));
    if (previousEvent) {
      store.remove("NftHistory", previousEvent.id);
      return;
    }
  }
}
