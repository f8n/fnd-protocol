import { BigDecimal, BigInt } from "@graphprotocol/graph-ts";

import {
  BuyReferralPaid,
  CreateFixedPriceSale,
  MintFromFixedPriceDrop,
} from "../../generated/NFTDropMarket/NFTDropMarketContract";
import { FixedPriceSale, FixedPriceSaleMint } from "../../generated/schema";
import { loadOrCreateAccount } from "../shared/accounts";
import { toETH } from "../shared/conversions";
import { loadOrCreateNFTContract } from "./nft";
import { loadOrCreateNFTMarketContract } from "./nftMarket";

export function handleBuyReferralPaid(event: BuyReferralPaid): void {
  // FixedPriceSale
  let fixedPriceSaleMint = FixedPriceSaleMint.load(event.transaction.hash.toHex());
  if (fixedPriceSaleMint) {
    let fixedPriceSale = FixedPriceSale.load(fixedPriceSaleMint.fixedPriceSale);
    if (fixedPriceSale) {
      fixedPriceSaleMint.buyReferrer = loadOrCreateAccount(event.params.buyReferrer).id;
      fixedPriceSaleMint.buyReferrerFee = toETH(event.params.buyReferrerFee);
      if (event.params.buyReferrerFee) {
        if (fixedPriceSale.buyReferrerFee) {
          fixedPriceSale.buyReferrerFee = (fixedPriceSale.buyReferrerFee as BigDecimal).plus(
            toETH(event.params.buyReferrerFee),
          );
        } else {
          fixedPriceSale.buyReferrerFee = toETH(event.params.buyReferrerFee);
        }
      }
      fixedPriceSaleMint.save();
      fixedPriceSale.save();
    }
    return;
  }
}

export function handleCreateFixedPriceSale(event: CreateFixedPriceSale): void {
  let fixedPriceSale = new FixedPriceSale(event.params.nftContract.toHex());
  fixedPriceSale.nftMarketContract = loadOrCreateNFTMarketContract(event.address).id;
  fixedPriceSale.nftContract = loadOrCreateNFTContract(event.params.nftContract).id;
  fixedPriceSale.mintCount = BigInt.zero();
  fixedPriceSale.seller = loadOrCreateAccount(event.params.seller).id;
  fixedPriceSale.unitPriceInETH = toETH(event.params.price);
  fixedPriceSale.limitPerAccount = event.params.limitPerAccount;
  fixedPriceSale.amountInETH = BigDecimal.zero();
  fixedPriceSale.dateCreated = event.block.timestamp;
  fixedPriceSale.transactionHashCreated = event.transaction.hash;
  fixedPriceSale.creatorRevenueInETH = BigDecimal.zero();
  fixedPriceSale.foundationRevenueInETH = BigDecimal.zero();
  fixedPriceSale.foundationProtocolFeeInETH = BigDecimal.zero();
  fixedPriceSale.buyReferrerFee = BigDecimal.zero();
  fixedPriceSale.save();
}

export function handleMintFromFixedPriceDrop(event: MintFromFixedPriceDrop): void {
  let fixedPriceSale = FixedPriceSale.load(event.params.nftContract.toHex());
  if (fixedPriceSale) {
    let fixedPriceSaleMint = FixedPriceSaleMint.load(event.transaction.hash.toHex());
    if (fixedPriceSaleMint) {
      fixedPriceSaleMint.fixedPriceSale = fixedPriceSale.id;
      fixedPriceSaleMint.buyer = loadOrCreateAccount(event.params.buyer).id;
      fixedPriceSaleMint.count = event.params.count;
      fixedPriceSaleMint.firstTokenId = event.params.firstTokenId;
      fixedPriceSaleMint.amountInETH = toETH(event.params.creatorRev).plus(toETH(event.params.totalFees));

      // update Fixed Price Sale
      fixedPriceSale.mintCount = fixedPriceSale.mintCount.plus(event.params.count);
      fixedPriceSale.amountInETH = fixedPriceSale.amountInETH.plus(fixedPriceSaleMint.amountInETH as BigDecimal);
      fixedPriceSale.creatorRevenueInETH = fixedPriceSale.creatorRevenueInETH.plus(toETH(event.params.creatorRev));
      fixedPriceSale.foundationRevenueInETH = fixedPriceSale.foundationRevenueInETH.plus(toETH(event.params.totalFees));
      fixedPriceSale.foundationProtocolFeeInETH = fixedPriceSale.foundationProtocolFeeInETH.plus(
        toETH(event.params.totalFees).minus(fixedPriceSale.buyReferrerFee as BigDecimal),
      );
      fixedPriceSale.latestMint = fixedPriceSaleMint.id;

      fixedPriceSaleMint.save();
      fixedPriceSale.save();
    }
  }
}
