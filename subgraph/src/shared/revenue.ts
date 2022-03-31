import { BigDecimal } from "@graphprotocol/graph-ts";
import { Account, Creator, Nft } from "../../generated/schema";

export function recordSale(
  nft: Nft,
  seller: Account,
  creatorRevenueInETH: BigDecimal | null,
  ownerRevenueInETH: BigDecimal | null,
  foundationRevenueInETH: BigDecimal | null,
): void {
  if (!creatorRevenueInETH || !ownerRevenueInETH || !foundationRevenueInETH) {
    // This should never occur
    return;
  }
  let amountInETH = creatorRevenueInETH.plus(ownerRevenueInETH).plus(foundationRevenueInETH);

  // Creator revenue & sales
  let creator: Creator | null;
  if (nft.creator) {
    creator = Creator.load(nft.creator as string);
  } else {
    creator = null;
  }
  if (creator) {
    creator.netRevenueInETH = creator.netRevenueInETH.plus(creatorRevenueInETH);
    creator.netSalesInETH = creator.netSalesInETH.plus(amountInETH);
    creator.save();
  }

  // Account revenue
  seller.netRevenueInETH = seller.netRevenueInETH.plus(ownerRevenueInETH);
  seller.save();

  // NFT revenue & sales
  nft.netSalesInETH = nft.netSalesInETH.plus(amountInETH);
  nft.netRevenueInETH = nft.netRevenueInETH.plus(creatorRevenueInETH);
  nft.isFirstSale = false;
  nft.lastSalePriceInETH = amountInETH;
  nft.save();
}
