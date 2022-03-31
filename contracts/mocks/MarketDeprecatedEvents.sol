// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

/**
 * @dev Historical (currently deprecated) events
 * that the subgraph depends on for historical transactions.
 */
contract MarketDeprecatedEvents {
  // From NFTMarketReserveAuction
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

  // From SendValueWithFallbackWithdraw
  /**
   * @notice [DEPRECATED] Emitted when an attempt to send ETH fails
   * or runs out of gas and the value is stored in escrow instead.
   * @param user The account which has escrowed ETH to withdraw.
   * @param amount The amount of ETH which has been added to the user's escrow balance.
   */
  event WithdrawPending(address indexed user, uint256 amount);
  /**
   * @notice [DEPRECATED] Emitted when escrowed funds are withdrawn.
   * @param user The account which has withdrawn ETH.
   * @param amount The amount of ETH which has been withdrawn.
   */
  event Withdrawal(address indexed user, uint256 amount);
}
