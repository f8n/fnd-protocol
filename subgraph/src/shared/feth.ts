import { Address, BigInt, ethereum } from "@graphprotocol/graph-ts";

import { Account, Feth, FethEscrow } from "../../generated/schema";
import { ZERO_BIG_DECIMAL } from "./constants";

interface EscrowEventParams {
  account: Address;
  amount: BigInt;
  expiration: BigInt;
}

interface EscrowEvent {
  params: EscrowEventParams;
  block: ethereum.Block;
  transaction: ethereum.Transaction;
}

export function getEscrowId<T extends EscrowEvent>(event: T): string {
  return event.params.account.toHex() + "-" + event.params.expiration.toString();
}

export function loadOrCreateFeth(account: Account, block: ethereum.Block): Feth {
  let feth = Feth.load(account.id);
  if (!feth) {
    feth = new Feth(account.id);
    feth.user = account.id;
    feth.balanceInETH = ZERO_BIG_DECIMAL;
    feth.dateLastUpdated = block.timestamp;
  }
  return feth;
}

export function loadOrCreateFethEscrow<T extends EscrowEvent>(event: T, account: Account): FethEscrow {
  const escrowId = getEscrowId(event);
  let fethEscrow = FethEscrow.load(escrowId);
  if (!fethEscrow) {
    fethEscrow = new FethEscrow(escrowId);
    fethEscrow.transactionHashCreated = event.transaction.hash;
    fethEscrow.amountInETH = ZERO_BIG_DECIMAL;

    // Placeholder for expiry (now), this should be immediately replaced by the actual expiry
    fethEscrow.dateExpiry = event.params.expiration;
  }

  // Ensure that the escrow is associated with the account's FETH balance
  let fethAccount = loadOrCreateFeth(account, event.block);
  fethAccount.save();
  fethEscrow.feth = fethAccount.id;

  return fethEscrow;
}
