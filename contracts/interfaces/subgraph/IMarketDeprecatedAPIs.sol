// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

/**
 * @dev Historical (currently deprecated) APIs
 * that the subgraph depends on for historical transactions.
 */
interface IMarketDeprecatedAPIs {
  function getIsPrimary(address nftContract, uint256 tokenId) external view returns (bool isPrimary);

  function getFees(
    address nftContract,
    uint256 tokenId,
    uint256 price
  )
    external
    view
    returns (
      uint256 totalFees,
      uint256 creatorRev,
      uint256 sellerRev
    );
}
