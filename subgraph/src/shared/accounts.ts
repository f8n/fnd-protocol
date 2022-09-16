import { Address } from "@graphprotocol/graph-ts";

import { Account } from "../../generated/schema";
import { ZERO_BIG_DECIMAL } from "./constants";

export function loadOrCreateAccount(address: Address): Account {
  let addressHex = address.toHex();
  let account = Account.load(addressHex);
  if (!account) {
    account = new Account(addressHex);
    account.netRevenueInETH = ZERO_BIG_DECIMAL;
    account.netRevenuePendingInETH = ZERO_BIG_DECIMAL;
    account.save();
  }
  return account as Account;
}
