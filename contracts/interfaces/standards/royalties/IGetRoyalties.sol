// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

interface IGetRoyalties {
  /**
   * @notice Get the creator royalties to be sent.
   * @dev The data is the same as when calling `getFeeRecipients` and `getFeeBps` separately.
   * @param tokenId The ID of the NFT to get royalties for.
   * @return recipients An array of addresses to which royalties should be sent.
   * @return royaltiesInBasisPoints The array of fees to be sent to each recipient, in basis points.
   */
  function getRoyalties(uint256 tokenId)
    external
    view
    returns (address payable[] memory recipients, uint256[] memory royaltiesInBasisPoints);
}
