// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

/**
 * @dev Historical (currently deprecated) APIs
 * that the subgraph depends on for historical transactions.
 */
interface IMarketDeprecatedAPIs {
  /**
   * @notice Emitted when the seller for an auction has been changed to a new account.
   * @dev Account migrations require approval from both the original account and Foundation.
   * @param auctionId The id of the auction that was updated.
   * @param originalSellerAddress The original address of the auction's seller.
   * @param newSellerAddress The new address for the auction's seller.
   */
  event ReserveAuctionSellerMigrated(
    uint256 indexed auctionId,
    address indexed originalSellerAddress,
    address indexed newSellerAddress
  );

  function getIsPrimary(address nftContract, uint256 tokenId) external view returns (bool isPrimary);

  function getFees(
    address nftContract,
    uint256 tokenId,
    uint256 price
  )
    external
    view
    returns (
      uint256 foundationFee,
      uint256 creatorRev,
      uint256 sellerRev
    );
}
