import { Address } from "@graphprotocol/graph-ts";

import { Creator } from "../../generated/schema";
import { loadOrCreateAccount } from "./accounts";
import { ZERO_BIG_DECIMAL } from "./constants";

export function loadOrCreateCreator(address: Address): Creator {
  let account = loadOrCreateAccount(address);
  let creator = Creator.load(account.id);
  if (!creator) {
    creator = new Creator(account.id);
    creator.account = account.id;
    creator.netSalesInETH = ZERO_BIG_DECIMAL;
    creator.netSalesPendingInETH = ZERO_BIG_DECIMAL;
    creator.netRevenueInETH = ZERO_BIG_DECIMAL;
    creator.netRevenuePendingInETH = ZERO_BIG_DECIMAL;
    creator.save();
  }
  return creator as Creator;
}
