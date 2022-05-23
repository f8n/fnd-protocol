import { BigDecimal } from "@graphprotocol/graph-ts";
import { BASIS_POINTS_PER_PERCENT, WEI_PER_ETH } from "./constants";

export function toPercent(basisPoints: bigint): BigDecimal {
  return basisPoints.toBigDecimal().div(BASIS_POINTS_PER_PERCENT);
}

export function toETH(wei: bigint): BigDecimal {
  return wei.toBigDecimal().div(WEI_PER_ETH);
}
