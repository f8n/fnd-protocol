import { ethereum } from "@graphprotocol/graph-ts";
import { Account, Nft, NftMarketOffer } from "../../generated/schema";
import { recordNftEvent } from "./events";

export function loadLatestOffer(nft: Nft): NftMarketOffer | null {
  if (!nft.mostRecentOffer) {
    return null;
  }
  let offer = NftMarketOffer.load(nft.mostRecentOffer as string);
  if (!offer || offer.status != "Open") {
    return null;
  }
  return offer;
}

export function outbidOrExpirePreviousOffer(
  event: ethereum.Event,
  nft: Nft,
  newBuyer: Account,
  newOffer: NftMarketOffer,
): boolean {
  let offer = loadLatestOffer(nft);
  if (!offer) {
    // New offer
    return false;
  }

  let isExpired = offer.dateExpires.lt(event.block.timestamp);
  if (isExpired) {
    // Previous offer expired
    offer.status = "Expired";
    offer.save();
    let buyer = Account.load(offer.buyer) as Account; // Buyer was set on offer made
    recordNftEvent(
      event,
      nft,
      "OfferExpired",
      buyer,
      null,
      "Foundation",
      null,
      null,
      event.block.timestamp,
      null,
      null,
      null,
      offer,
    );
    return false;
  }

  // Previous offer was outbid
  offer.status = "Outbid";
  offer.dateOutbid = event.block.timestamp;
  offer.transactionHashOutbid = event.transaction.hash;
  offer.offerOutbidBy = newOffer.id;
  newOffer.outbidOffer = offer.id;
  offer.save();

  let isIncreased = offer.buyer == newBuyer.id;
  return isIncreased;
}
