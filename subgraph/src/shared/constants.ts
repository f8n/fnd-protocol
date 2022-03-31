import { BigInt } from "@graphprotocol/graph-ts";

export const ZERO_BYTES_32_STRING = "0x0000000000000000000000000000000000000000000000000000000000000000";
export let ZERO_BIG_INT = BigInt.fromI32(0);
export let ONE_BIG_INT = BigInt.fromI32(1);
export let ZERO_BIG_DECIMAL = ZERO_BIG_INT.toBigDecimal();
export let BASIS_POINTS = BigInt.fromI32(10000);
export let BASIS_POINTS_PER_PERCENT = BigInt.fromI32(100).toBigDecimal();
export let WEI_PER_ETH = BigInt.fromI32(10).pow(18).toBigDecimal();
export let ZERO_ADDRESS_STRING = "0x0000000000000000000000000000000000000000";
export let ONE_MINUTE = BigInt.fromI32(60);
export let TEN_MINUTES = ONE_MINUTE.times(BigInt.fromI32(10));
