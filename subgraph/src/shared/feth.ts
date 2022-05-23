import { Address } from "@graphprotocol/graph-ts";
import { Account, Feth, FethEscrow } from "../../generated/schema";
import { ZERO_BIG_DECIMAL } from "./constants";

interface EscrowEventParams {
  account: Address;
  amount: bigint;
  expiration: bigint;
}

interface EscrowEvent {
  params: EscrowEventParams;
}

export function getEscrowId<T extends EscrowEvent>(event: T): string {
  return event.params.account.toHex() + "-" + event.params.expiration.toString();
}

export function loadOrCreateFeth(account: Account): Feth {
  let feth = Feth.load(account.id);
  if (!feth) {
    feth = new Feth(account.id);
    feth.user = account.id;
    feth.balanceInETH = ZERO_BIG_DECIMAL;
  }
  return feth;
}

export function loadOrCreateFethEscrow<T extends EscrowEvent>(event: T): FethEscrow {
  const escrowId = getEscrowId(event);
  let feth = FethEscrow.load(escrowId);
  if (!feth) {
    feth = new FethEscrow(escrowId);
    feth.amountInETH = ZERO_BIG_DECIMAL;
  }
  return feth;
}
