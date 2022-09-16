import { BigDecimal, BigInt } from "@graphprotocol/graph-ts";

import { BASIS_POINTS_PER_PERCENT, WEI_PER_ETH } from "./constants";

export function toPercent(basisPoints: BigInt): BigDecimal {
  return basisPoints.toBigDecimal().div(BASIS_POINTS_PER_PERCENT);
}

export function toETH(wei: BigInt): BigDecimal {
  return wei.toBigDecimal().div(WEI_PER_ETH);
}
