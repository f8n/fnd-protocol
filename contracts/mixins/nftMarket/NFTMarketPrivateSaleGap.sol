// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

/**
 * @title Reserves space previously occupied by private sales.
 * @author batu-inal & HardlyDifficult
 */
abstract contract NFTMarketPrivateSaleGap {
  // Original data:
  // bytes32 private __gap_was_DOMAIN_SEPARATOR;
  // mapping(address => mapping(uint256 => mapping(address => mapping(address => mapping(uint256 =>
  //   mapping(uint256 => bool)))))) private privateSaleInvalidated;
  // uint256[999] private __gap;

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   * @dev 1 slot was consumed by privateSaleInvalidated.
   */
  uint256[1001] private __gap;
}
