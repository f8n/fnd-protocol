import { Address, BigDecimal, BigInt } from "@graphprotocol/graph-ts";

import {
  OfferCanceledByAdmin,
  PrivateSaleFinalized,
  ReserveAuctionCanceledByAdmin,
  ReserveAuctionSellerMigrated,
} from "../../generated/MarketDeprecatedEvents/MarketDeprecatedEvents";
import { IMarketDeprecatedAPIs } from "../../generated/NFTMarketContract/IMarketDeprecatedAPIs";
import {
  BuyPriceAccepted,
  BuyPriceCanceled,
  BuyPriceInvalidated,
  BuyPriceSet,
  BuyReferralPaid,
  OfferAccepted,
  OfferInvalidated,
  OfferMade,
  ReserveAuctionBidPlaced,
  ReserveAuctionCanceled,
  ReserveAuctionCreated,
  ReserveAuctionFinalized,
  ReserveAuctionInvalidated,
  ReserveAuctionUpdated,
} from "../../generated/NFTMarketContract/NFTMarketContract";
import {
  Account,
  Creator,
  Nft,
  NftMarketAuction,
  NftMarketBid,
  NftMarketBuyNow,
  NftMarketContract,
  NftMarketOffer,
  PrivateSale,
} from "../../generated/schema";
import { loadOrCreateAccount } from "../shared/accounts";
import { loadLatestBuyNow } from "../shared/buyNow";
import { BASIS_POINTS, ONE_BIG_INT, ZERO_ADDRESS_STRING, ZERO_BIG_DECIMAL, ZERO_BIG_INT } from "../shared/constants";
import { toETH } from "../shared/conversions";
import { recordNftEvent, removePreviousTransferEvent } from "../shared/events";
import { getLogId } from "../shared/ids";
import { loadLatestOffer, outbidOrExpirePreviousOffer } from "../shared/offers";
import { recordSale } from "../shared/revenue";
import { loadOrCreateNFT } from "./nft";

export function loadOrCreateNFTMarketContract(address: Address): NftMarketContract {
  let nftMarketContract = NftMarketContract.load(address.toHex());
  if (!nftMarketContract) {
    nftMarketContract = new NftMarketContract(address.toHex());
    nftMarketContract.numberOfBidsPlaced = ZERO_BIG_INT;
    nftMarketContract.save();
  }
  return nftMarketContract as NftMarketContract;
}

function loadAuction(marketAddress: Address, auctionId: BigInt): NftMarketAuction | null {
  return NftMarketAuction.load(marketAddress.toHex() + "-" + auctionId.toString());
}

export function handleReserveAuctionBidPlaced(event: ReserveAuctionBidPlaced): void {
  let auction = loadAuction(event.address, event.params.auctionId);
  if (!auction) {
    return;
  }

  // Save new high bid
  let currentBid = new NftMarketBid(auction.id + "-" + getLogId(event));

  let nft = Nft.load(auction.nft) as Nft;
  let creator: Creator | null;
  if (nft.creator) {
    creator = Creator.load(nft.creator as string);
  } else {
    creator = null;
  }
  let owner = Account.load(auction.seller) as Account;

  // Update previous high bid
  let highestBid = auction.highestBid;
  if (highestBid) {
    let previousBid = NftMarketBid.load(highestBid) as NftMarketBid;
    previousBid.status = "Outbid";
    previousBid.dateLeftActiveStatus = event.block.timestamp;
    previousBid.transactionHashLeftActiveStatus = event.transaction.hash;
    previousBid.outbidByBid = currentBid.id;
    previousBid.save();

    currentBid.bidThisOutbid = previousBid.id;

    // Subtract the previous pending value
    if (creator) {
      creator.netRevenuePendingInETH = creator.netRevenuePendingInETH.minus(auction.creatorRevenueInETH as BigDecimal);
      creator.netSalesPendingInETH = creator.netSalesPendingInETH.minus(
        (auction.creatorRevenueInETH as BigDecimal)
          .plus(auction.ownerRevenueInETH as BigDecimal)
          .plus(auction.foundationRevenueInETH as BigDecimal),
      );
    }
    owner.netRevenuePendingInETH = owner.netRevenuePendingInETH.plus(auction.ownerRevenueInETH as BigDecimal);
    // creator and owner are saved below
  } else {
    auction.dateStarted = event.block.timestamp;
  }

  currentBid.nftMarketAuction = auction.id;
  currentBid.nft = auction.nft;
  let bidder = loadOrCreateAccount(event.params.bidder);
  currentBid.bidder = bidder.id;
  currentBid.datePlaced = event.block.timestamp;
  currentBid.transactionHashPlaced = event.transaction.hash;
  currentBid.amountInETH = toETH(event.params.amount);
  currentBid.status = "Highest";
  currentBid.seller = auction.seller;

  let marketContractDeprecatedAPIs = IMarketDeprecatedAPIs.bind(event.address);

  // Update isPrimary with each bid since some secondary logic may have changed for 3rd party contracts after the initial listing
  let isPrimarySaleResult = marketContractDeprecatedAPIs.try_getIsPrimary(
    Address.fromString(nft.nftContract),
    nft.tokenId,
  );
  if (!isPrimarySaleResult.reverted) {
    auction.isPrimarySale = isPrimarySaleResult.value;
  } else {
    auction.isPrimarySale = nft.isFirstSale && auction.seller == nft.creator;
  }

  // Calculate the expected revenue for this bid
  let totalFees: BigInt;
  let creatorRev: BigInt;
  let sellerRev: BigInt;
  // getFees is failing in Figment only, this try/else block works around that issue
  let fees = marketContractDeprecatedAPIs.try_getFees(
    Address.fromString(nft.nftContract),
    nft.tokenId,
    event.params.amount,
  );
  if (!fees.reverted) {
    // Fees 0: primaryF8NFee, 1: creatorRev, 2: sellerRevenue
    totalFees = fees.value.value0;
    creatorRev = fees.value.value1;
    sellerRev = fees.value.value2;
  } else {
    // Estimate fees
    if (auction.isPrimarySale) {
      totalFees = event.params.amount.times(BigInt.fromI32(1500)).div(BASIS_POINTS);
      creatorRev = event.params.amount.times(BigInt.fromI32(8500)).div(BASIS_POINTS);
      sellerRev = ZERO_BIG_INT;
    } else {
      totalFees = event.params.amount.times(BigInt.fromI32(500)).div(BASIS_POINTS);
      creatorRev = event.params.amount.times(BigInt.fromI32(1000)).div(BASIS_POINTS);
      sellerRev = event.params.amount.times(BigInt.fromI32(8500)).div(BASIS_POINTS);
    }
  }

  auction.foundationRevenueInETH = toETH(totalFees);
  if (auction.seller == nft.creator) {
    auction.creatorRevenueInETH = toETH(creatorRev.plus(sellerRev));
    auction.ownerRevenueInETH = ZERO_BIG_DECIMAL;
  } else {
    auction.creatorRevenueInETH = toETH(creatorRev);
    auction.ownerRevenueInETH = toETH(sellerRev);
  }

  // Add in the new pending revenue
  let saleAmountInETH = (auction.creatorRevenueInETH as BigDecimal)
    .plus(auction.ownerRevenueInETH as BigDecimal)
    .plus(auction.foundationRevenueInETH as BigDecimal);
  if (creator) {
    creator.netRevenuePendingInETH = creator.netRevenuePendingInETH.plus(auction.creatorRevenueInETH as BigDecimal);
    creator.netSalesPendingInETH = creator.netSalesPendingInETH.plus(saleAmountInETH);
    creator.save();
  }
  owner.netRevenuePendingInETH = owner.netRevenuePendingInETH.plus(auction.ownerRevenueInETH as BigDecimal);
  owner.save();
  nft.netRevenuePendingInETH = nft.netRevenuePendingInETH.plus(auction.creatorRevenueInETH as BigDecimal);
  nft.netSalesPendingInETH = nft.netSalesPendingInETH.plus(saleAmountInETH);
  nft.save();

  if (!auction.highestBid) {
    auction.initialBid = currentBid.id;
    currentBid.extendedAuction = false;
  } else {
    currentBid.extendedAuction = auction.dateEnding != event.params.endTime;
  }
  auction.dateEnding = event.params.endTime;
  auction.numberOfBids = auction.numberOfBids.plus(ONE_BIG_INT);
  auction.bidVolumeInETH = auction.bidVolumeInETH.plus(currentBid.amountInETH);
  currentBid.save();
  auction.highestBid = currentBid.id;
  auction.save();

  // Count bids
  let market = loadOrCreateNFTMarketContract(event.address);
  market.numberOfBidsPlaced = market.numberOfBidsPlaced.plus(ONE_BIG_INT);
  market.save();

  recordNftEvent(event, nft as Nft, "Bid", bidder, auction, "Foundation", currentBid.amountInETH);
}

export function handleReserveAuctionCanceled(event: ReserveAuctionCanceled): void {
  let auction = loadAuction(event.address, event.params.auctionId);
  if (!auction) {
    return;
  }

  auction.status = "Canceled";
  auction.dateCanceled = event.block.timestamp;
  auction.transactionHashCanceled = event.transaction.hash;
  auction.save();

  let nft = Nft.load(auction.nft) as Nft;
  nft.mostRecentActiveAuction = nft.latestFinalizedAuction;
  nft.save();

  removePreviousTransferEvent(event);
  recordNftEvent(
    event,
    Nft.load(auction.nft) as Nft,
    "Unlisted",
    Account.load(auction.seller) as Account,
    auction,
    "Foundation",
  );
}

export function handleReserveAuctionCanceledByAdmin(event: ReserveAuctionCanceledByAdmin): void {
  let auction = loadAuction(event.address, event.params.auctionId);
  if (!auction) {
    return;
  }

  auction.status = "Canceled";
  auction.canceledReason = event.params.reason;
  auction.dateCanceled = event.block.timestamp;
  auction.transactionHashCanceled = event.transaction.hash;
  auction.save();

  let nft = Nft.load(auction.nft) as Nft;
  nft.mostRecentActiveAuction = nft.latestFinalizedAuction;
  nft.save();

  removePreviousTransferEvent(event);
  recordNftEvent(
    event,
    Nft.load(auction.nft) as Nft,
    "Unlisted",
    loadOrCreateAccount(event.transaction.from),
    auction,
    "Foundation",
  );
}

export function handleReserveAuctionCreated(event: ReserveAuctionCreated): void {
  let nft = loadOrCreateNFT(event.params.nftContract, event.params.tokenId, event);
  let marketContract = loadOrCreateNFTMarketContract(event.address);
  let auction = new NftMarketAuction(marketContract.id + "-" + event.params.auctionId.toString());
  auction.nftMarketContract = marketContract.id;
  auction.auctionId = event.params.auctionId;
  auction.nft = nft.id;
  auction.nftContract = event.params.nftContract.toHex();
  auction.status = "Open";
  let seller = loadOrCreateAccount(event.params.seller);
  auction.seller = seller.id;
  auction.duration = event.params.duration;
  auction.dateCreated = event.block.timestamp;
  auction.transactionHashCreated = event.transaction.hash;
  auction.extensionDuration = event.params.extensionDuration;
  auction.reservePriceInETH = toETH(event.params.reservePrice);
  let marketContractDeprecatedAPIs = IMarketDeprecatedAPIs.bind(event.address);
  let isPrimarySaleResult = marketContractDeprecatedAPIs.try_getIsPrimary(
    event.params.nftContract,
    event.params.tokenId,
  );
  if (!isPrimarySaleResult.reverted) {
    auction.isPrimarySale = isPrimarySaleResult.value;
  } else {
    auction.isPrimarySale = nft.isFirstSale && auction.seller == nft.creator;
  }
  auction.numberOfBids = ZERO_BIG_INT;
  auction.bidVolumeInETH = ZERO_BIG_DECIMAL;
  auction.save();

  nft.ownedOrListedBy = seller.id;
  nft.mostRecentAuction = auction.id;
  nft.mostRecentActiveAuction = auction.id;
  nft.save();

  removePreviousTransferEvent(event);
  recordNftEvent(event, nft as Nft, "Listed", seller, auction, "Foundation", auction.reservePriceInETH);
}

export function handleReserveAuctionFinalized(event: ReserveAuctionFinalized): void {
  let auction = loadAuction(event.address, event.params.auctionId);
  if (!auction) {
    return;
  }

  auction.status = "Finalized";
  auction.dateFinalized = event.block.timestamp;
  auction.ownerRevenueInETH = toETH(event.params.sellerRev);
  auction.creatorRevenueInETH = toETH(event.params.creatorRev);
  auction.foundationRevenueInETH = toETH(event.params.totalFees);
  let currentBid = NftMarketBid.load(auction.highestBid as string) as NftMarketBid;
  currentBid.status = "FinalizedWinner";
  currentBid.dateLeftActiveStatus = event.block.timestamp;
  currentBid.transactionHashLeftActiveStatus = event.transaction.hash;
  currentBid.save();
  let nft = Nft.load(auction.nft) as Nft;
  nft.latestFinalizedAuction = auction.id;
  nft.lastSalePriceInETH = currentBid.amountInETH;
  nft.save();

  let creator: Creator | null;
  if (nft.creator) {
    creator = Creator.load(nft.creator as string);
  } else {
    creator = null;
  }
  let owner = Account.load(auction.seller) as Account;

  // Subtract from pending revenue
  let saleAmountInETH = (auction.creatorRevenueInETH as BigDecimal)
    .plus(auction.ownerRevenueInETH as BigDecimal)
    .plus(auction.foundationRevenueInETH as BigDecimal);
  if (creator) {
    creator.netRevenuePendingInETH = creator.netRevenuePendingInETH.minus(auction.creatorRevenueInETH as BigDecimal);
    creator.netSalesPendingInETH = creator.netSalesPendingInETH.minus(saleAmountInETH);
  }
  if (!auction.buyReferrerSellerFee) {
    auction.buyReferrerSellerFee = toETH(ZERO_BIG_INT);
  }
  if (!auction.buyReferrerFee) {
    auction.buyReferrerFee = toETH(ZERO_BIG_INT);
  }
  auction.foundationProtocolFeeInETH = toETH(event.params.totalFees).minus(auction.buyReferrerFee!); // eslint-disable-line @typescript-eslint/no-non-null-assertion

  owner.netRevenuePendingInETH = owner.netRevenuePendingInETH.minus(auction.ownerRevenueInETH as BigDecimal);
  nft.netRevenuePendingInETH = nft.netRevenuePendingInETH.minus(auction.creatorRevenueInETH as BigDecimal);
  nft.netSalesPendingInETH = nft.netSalesPendingInETH.minus(saleAmountInETH);
  nft.save();
  auction.save();

  recordSale(nft, owner, auction.creatorRevenueInETH, auction.ownerRevenueInETH, auction.foundationRevenueInETH);

  // TODO: Ideally this row would be added when the auction ended instead of waiting for settlement
  recordNftEvent(
    event,
    nft as Nft,
    "Sold",
    Account.load(currentBid.bidder) as Account,
    auction,
    "Foundation",
    currentBid.amountInETH,
    null,
    auction.dateEnding,
  );
  removePreviousTransferEvent(event);
  recordNftEvent(
    event,
    nft as Nft,
    "Settled",
    loadOrCreateAccount(event.transaction.from),
    auction,
    "Foundation",
    null,
    Account.load(currentBid.bidder) as Account,
  );
}

export function handleReserveAuctionUpdated(event: ReserveAuctionUpdated): void {
  let auction = loadAuction(event.address, event.params.auctionId);
  if (!auction) {
    return;
  }

  auction.reservePriceInETH = toETH(event.params.reservePrice);
  auction.save();

  recordNftEvent(
    event,
    Nft.load(auction.nft) as Nft,
    "PriceChanged",
    Account.load(auction.seller) as Account,
    auction,
    "Foundation",
    auction.reservePriceInETH,
  );
}

export function handleReserveAuctionInvalidated(event: ReserveAuctionInvalidated): void {
  let auction = loadAuction(event.address, event.params.auctionId);
  if (!auction) {
    return;
  }

  auction.status = "Invalidated";
  auction.dateInvalidated = event.block.timestamp;
  auction.transactionHashInvalidated = event.transaction.hash;
  auction.save();

  let nft = Nft.load(auction.nft) as Nft;
  nft.mostRecentActiveAuction = nft.latestFinalizedAuction;
  nft.save();

  recordNftEvent(event, nft, "AuctionInvalidated", Account.load(auction.seller) as Account, auction, "Foundation");
}

export function handleReserveAuctionSellerMigrated(event: ReserveAuctionSellerMigrated): void {
  let auction = loadAuction(event.address, event.params.auctionId) as NftMarketAuction;
  let newAccount = loadOrCreateAccount(event.params.newSellerAddress);
  auction.seller = newAccount.id;
  auction.save();
  let nft = Nft.load(auction.nft);
  if (!nft) {
    return;
  }

  nft.ownedOrListedBy = newAccount.id;
  nft.save();

  let originalAccount = loadOrCreateAccount(event.params.originalSellerAddress);
  recordNftEvent(event, nft as Nft, "SellerMigrated", originalAccount, auction, "Foundation", null, newAccount);
}

export function handlePrivateSaleFinalized(event: PrivateSaleFinalized): void {
  let nft = loadOrCreateNFT(event.params.nftContract, event.params.tokenId, event);
  let seller = loadOrCreateAccount(event.params.seller);
  let buyer = loadOrCreateAccount(event.params.buyer);

  let privateSale = new PrivateSale(getLogId(event));
  privateSale.nft = nft.id;
  privateSale.seller = seller.id;
  privateSale.buyer = buyer.id;
  if (seller.id == nft.creator) {
    privateSale.creatorRevenueInETH = toETH(event.params.creatorRev.plus(event.params.sellerRev));
    privateSale.ownerRevenueInETH = ZERO_BIG_DECIMAL;
  } else {
    privateSale.creatorRevenueInETH = toETH(event.params.creatorRev);
    privateSale.ownerRevenueInETH = toETH(event.params.sellerRev);
  }
  privateSale.foundationRevenueInETH = toETH(event.params.totalFees);
  privateSale.amountInETH = privateSale.creatorRevenueInETH
    .plus(privateSale.foundationRevenueInETH)
    .plus(privateSale.ownerRevenueInETH);
  privateSale.dateSold = event.block.timestamp;
  privateSale.transactionHashSold = event.transaction.hash;
  privateSale.deadline = event.params.deadline;
  privateSale.isPrimarySale = nft.isFirstSale && privateSale.seller == nft.creator;
  privateSale.save();

  removePreviousTransferEvent(event);
  recordNftEvent(
    event,
    nft as Nft,
    "PrivateSale",
    seller,
    null,
    "Foundation",
    privateSale.amountInETH,
    buyer,
    null,
    null,
    null,
    privateSale,
  );

  recordSale(
    nft,
    seller,
    privateSale.creatorRevenueInETH,
    privateSale.ownerRevenueInETH,
    privateSale.foundationRevenueInETH,
  );
}

// TODO: Track splits account/creator revenue/sales

export function handleOfferMade(event: OfferMade): void {
  let nft = loadOrCreateNFT(event.params.nftContract, event.params.tokenId, event);
  let buyer = loadOrCreateAccount(event.params.buyer);
  let offer = new NftMarketOffer(getLogId(event));
  let isIncrease = outbidOrExpirePreviousOffer(event, nft, buyer, offer);
  let amountInETH = toETH(event.params.amount);
  offer.nftMarketContract = loadOrCreateNFTMarketContract(event.address).id;
  offer.nft = nft.id;
  offer.nftContract = nft.nftContract;
  offer.status = "Open";
  offer.buyer = buyer.id;
  offer.amountInETH = amountInETH;
  offer.dateCreated = event.block.timestamp;
  offer.transactionHashCreated = event.transaction.hash;
  offer.dateExpires = event.params.expiration;
  offer.save();
  recordNftEvent(
    event,
    nft,
    isIncrease ? "OfferChanged" : "OfferMade",
    buyer,
    null,
    "Foundation",
    amountInETH,
    null,
    null,
    null,
    null,
    null,
    offer,
  );
  nft.mostRecentOffer = offer.id;
  nft.save();
}

export function handleOfferAccepted(event: OfferAccepted): void {
  let nft = loadOrCreateNFT(event.params.nftContract, event.params.tokenId, event);
  let offer = loadLatestOffer(nft);
  if (!offer) {
    return;
  }
  offer.status = "Accepted";
  let buyer = loadOrCreateAccount(event.params.buyer);
  let seller = loadOrCreateAccount(event.params.seller);
  offer.seller = seller.id;
  offer.dateAccepted = event.block.timestamp;
  offer.transactionHashAccepted = event.transaction.hash;
  offer.creatorRevenueInETH = toETH(event.params.creatorRev);
  offer.foundationRevenueInETH = toETH(event.params.totalFees);
  offer.ownerRevenueInETH = toETH(event.params.sellerRev);
  if (!offer.buyReferrerSellerFee) {
    offer.buyReferrerSellerFee = toETH(ZERO_BIG_INT);
  }
  if (!offer.buyReferrerFee) {
    offer.buyReferrerFee = toETH(ZERO_BIG_INT);
  }
  offer.foundationProtocolFeeInETH = toETH(event.params.totalFees).minus(offer.buyReferrerFee!); // eslint-disable-line @typescript-eslint/no-non-null-assertion

  offer.isPrimarySale = nft.isFirstSale && offer.seller == nft.creator;
  offer.save();
  removePreviousTransferEvent(event); // Only applicable if the NFT was escrowed
  recordNftEvent(
    event,
    nft,
    "OfferAccepted",
    seller,
    null,
    "Foundation",
    offer.amountInETH,
    buyer,
    null,
    null,
    null,
    null,
    offer,
  );
  recordSale(nft, seller, offer.creatorRevenueInETH, offer.ownerRevenueInETH, offer.foundationRevenueInETH);
}

export function handleOfferInvalidated(event: OfferInvalidated): void {
  let nft = loadOrCreateNFT(event.params.nftContract, event.params.tokenId, event);
  let offer = loadLatestOffer(nft);
  if (!offer) {
    return;
  }
  let buyer = Account.load(offer.buyer) as Account; // Buyer was set on offer made
  offer.status = "Invalidated";
  offer.dateInvalidated = event.block.timestamp;
  offer.transactionHashInvalidated = event.transaction.hash;
  offer.save();
  recordNftEvent(event, nft, "OfferInvalidated", buyer, null, "Foundation", null, null, null, null, null, null, offer);
}

export function handleOfferCanceledByAdmin(event: OfferCanceledByAdmin): void {
  let nft = loadOrCreateNFT(event.params.nftContract, event.params.tokenId, event);
  let offer = loadLatestOffer(nft);
  if (!offer) {
    return;
  }
  let buyer = Account.load(offer.buyer) as Account; // Buyer was set on offer made
  offer.status = "Canceled";
  offer.dateCanceled = event.block.timestamp;
  offer.transactionHashCanceled = event.transaction.hash;
  offer.save();
  recordNftEvent(event, nft, "OfferCanceled", buyer, null, "Foundation", null, null, null, null, null, null, offer);
}

export function handleBuyPriceSet(event: BuyPriceSet): void {
  let nft = loadOrCreateNFT(event.params.nftContract, event.params.tokenId, event);
  let seller = loadOrCreateAccount(event.params.seller);
  let buyNow = loadLatestBuyNow(nft);
  if (!buyNow) {
    buyNow = new NftMarketBuyNow(getLogId(event));
  }
  let amountInETH = toETH(event.params.price);
  buyNow.nftMarketContract = loadOrCreateNFTMarketContract(event.address).id;
  buyNow.nft = nft.id;
  buyNow.nftContract = nft.nftContract;
  buyNow.status = "Open";
  buyNow.seller = seller.id;
  buyNow.amountInETH = amountInETH;
  buyNow.dateCreated = event.block.timestamp;
  buyNow.transactionHashCreated = event.transaction.hash;
  buyNow.save();
  removePreviousTransferEvent(event);
  recordNftEvent(
    event,
    nft,
    "BuyPriceSet",
    seller,
    null,
    "Foundation",
    amountInETH,
    null,
    null,
    null,
    null,
    null,
    null,
    buyNow,
  );
  nft.mostRecentBuyNow = buyNow.id;
  nft.ownedOrListedBy = seller.id;
  nft.save();
}

export function handleBuyPriceAccepted(event: BuyPriceAccepted): void {
  let nft = loadOrCreateNFT(event.params.nftContract, event.params.tokenId, event);
  let buyNow = loadLatestBuyNow(nft);
  if (!buyNow) {
    return;
  }
  buyNow.status = "Accepted";
  let buyer = loadOrCreateAccount(event.params.buyer);
  let seller = loadOrCreateAccount(event.params.seller);
  buyNow.buyer = buyer.id;
  buyNow.seller = seller.id;
  buyNow.dateAccepted = event.block.timestamp;
  buyNow.transactionHashAccepted = event.transaction.hash;
  buyNow.creatorRevenueInETH = toETH(event.params.creatorRev);
  buyNow.foundationRevenueInETH = toETH(event.params.totalFees);
  buyNow.ownerRevenueInETH = toETH(event.params.sellerRev);
  if (!buyNow.buyReferrerSellerFee) {
    buyNow.buyReferrerSellerFee = toETH(ZERO_BIG_INT);
  }
  if (!buyNow.buyReferrerFee) {
    buyNow.buyReferrerFee = toETH(ZERO_BIG_INT);
  }
  buyNow.foundationProtocolFeeInETH = toETH(event.params.totalFees).minus(buyNow.buyReferrerFee!); // eslint-disable-line @typescript-eslint/no-non-null-assertion
  buyNow.isPrimarySale = nft.isFirstSale && buyNow.seller == nft.creator;
  buyNow.save();

  removePreviousTransferEvent(event);
  recordNftEvent(
    event,
    nft,
    "BuyPriceAccepted",
    seller,
    null,
    "Foundation",
    buyNow.amountInETH,
    buyer,
    null,
    null,
    null,
    null,
    null,
    buyNow,
  );
  recordSale(nft, seller, buyNow.creatorRevenueInETH, buyNow.ownerRevenueInETH, buyNow.foundationRevenueInETH);
}

export function handleBuyPriceInvalidated(event: BuyPriceInvalidated): void {
  let nft = loadOrCreateNFT(event.params.nftContract, event.params.tokenId, event);
  let buyNow = loadLatestBuyNow(nft);
  if (!buyNow) {
    return;
  }
  let seller = Account.load(buyNow.seller) as Account;
  buyNow.status = "Invalidated";
  buyNow.dateInvalidated = event.block.timestamp;
  buyNow.transactionHashInvalidated = event.transaction.hash;
  buyNow.save();
  recordNftEvent(
    event,
    nft,
    "BuyPriceInvalidated",
    seller,
    null,
    "Foundation",
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    buyNow,
  );
}

export function handleBuyPriceCanceled(event: BuyPriceCanceled): void {
  let nft = loadOrCreateNFT(event.params.nftContract, event.params.tokenId, event);
  let buyNow = loadLatestBuyNow(nft);
  if (!buyNow) {
    return;
  }
  let seller = Account.load(buyNow.seller) as Account;
  buyNow.status = "Canceled";
  buyNow.dateCanceled = event.block.timestamp;
  buyNow.transactionHashCanceled = event.transaction.hash;
  buyNow.save();
  removePreviousTransferEvent(event);
  recordNftEvent(
    event,
    nft,
    "BuyPriceCanceled",
    seller,
    null,
    "Foundation",
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    buyNow,
  );
}

export function handleBuyReferralPaid(event: BuyReferralPaid): void {
  let nft = loadOrCreateNFT(event.params.nftContract, event.params.tokenId, event);
  let buyNow = loadLatestBuyNow(nft);
  if (buyNow) {
    buyNow.buyReferrerFee = toETH(event.params.buyReferrerFee);
    buyNow.buyReferrerSellerFee = toETH(event.params.buyReferrerSellerFee);
    if (event.params.buyReferrer.toHex() != ZERO_ADDRESS_STRING) {
      buyNow.buyReferrer = loadOrCreateAccount(event.params.buyReferrer).id;
    }
    buyNow.save();
    return;
  }
  let mostRecentActiveAuction = nft.mostRecentActiveAuction;
  if (mostRecentActiveAuction) {
    let auction = NftMarketAuction.load(mostRecentActiveAuction);
    if (auction && auction.status == "Open") {
      auction.buyReferrerFee = toETH(event.params.buyReferrerFee);
      auction.buyReferrerSellerFee = toETH(event.params.buyReferrerSellerFee);
      if (event.params.buyReferrer.toHex() != ZERO_ADDRESS_STRING) {
        auction.buyReferrer = loadOrCreateAccount(event.params.buyReferrer).id;
      }
      auction.save();
      return;
    }
  }
  // Offer lookup should be done last since an NFT bought
  // using BuyNow/Auctions does not invalidate an open Offer.
  let offer = loadLatestOffer(nft);
  if (offer) {
    offer.buyReferrerFee = toETH(event.params.buyReferrerFee);
    offer.buyReferrerSellerFee = toETH(event.params.buyReferrerSellerFee);
    if (event.params.buyReferrer.toHex() != ZERO_ADDRESS_STRING) {
      offer.buyReferrer = loadOrCreateAccount(event.params.buyReferrer).id;
    }
    offer.save();
    return;
  }
}
