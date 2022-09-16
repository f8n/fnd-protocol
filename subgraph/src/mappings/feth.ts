import { BalanceLocked, BalanceUnlocked, ETHWithdrawn, Transfer } from "../../generated/Feth/FethContract";
import { loadOrCreateAccount } from "../shared/accounts";
import { ZERO_ADDRESS_STRING, ZERO_BIG_DECIMAL } from "../shared/constants";
import { toETH } from "../shared/conversions";
import { loadOrCreateFeth, loadOrCreateFethEscrow } from "../shared/feth";

export function handleTransfer(event: Transfer): void {
  if (event.params.from.toHex() != ZERO_ADDRESS_STRING) {
    let from = loadOrCreateAccount(event.params.from);
    let fethFrom = loadOrCreateFeth(from, event.block);
    fethFrom.balanceInETH = fethFrom.balanceInETH.minus(toETH(event.params.amount));
    fethFrom.dateLastUpdated = event.block.timestamp;
    fethFrom.save();
  }

  let to = loadOrCreateAccount(event.params.to);
  let fethTo = loadOrCreateFeth(to, event.block);
  fethTo.balanceInETH = fethTo.balanceInETH.plus(toETH(event.params.amount));
  fethTo.dateLastUpdated = event.block.timestamp;
  fethTo.save();
}

export function handleETHWithdrawn(event: ETHWithdrawn): void {
  let from = loadOrCreateAccount(event.params.from);
  let fethFrom = loadOrCreateFeth(from, event.block);
  fethFrom.balanceInETH = fethFrom.balanceInETH.minus(toETH(event.params.amount));
  fethFrom.dateLastUpdated = event.block.timestamp;
  fethFrom.save();
}

export function handleBalanceLocked(event: BalanceLocked): void {
  let to = loadOrCreateAccount(event.params.account);
  let fethTo = loadOrCreateFeth(to, event.block);
  fethTo.balanceInETH = fethTo.balanceInETH.plus(toETH(event.params.valueDeposited));
  fethTo.dateLastUpdated = event.block.timestamp;
  fethTo.save();
  let escrow = loadOrCreateFethEscrow(event, to);
  if (escrow.dateRemoved) {
    escrow.amountInETH = toETH(event.params.amount);
    escrow.dateRemoved = null;
    escrow.transactionHashRemoved = null;
  } else {
    escrow.amountInETH = escrow.amountInETH.plus(toETH(event.params.amount));
  }

  escrow.dateExpiry = event.params.expiration;
  escrow.transactionHashCreated = event.transaction.hash;
  escrow.save();
}

export function handleBalanceUnlocked(event: BalanceUnlocked): void {
  let from = loadOrCreateAccount(event.params.account);
  let escrow = loadOrCreateFethEscrow(event, from);
  escrow.amountInETH = escrow.amountInETH.minus(toETH(event.params.amount));
  if (escrow.amountInETH.equals(ZERO_BIG_DECIMAL)) {
    escrow.transactionHashRemoved = event.transaction.hash;
    escrow.dateRemoved = event.block.timestamp;
  }
  escrow.save();
}
