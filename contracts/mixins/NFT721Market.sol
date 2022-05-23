// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../interfaces/IGetRoyalties.sol";
import "../interfaces/IGetFees.sol";
import "../interfaces/IRoyaltyInfo.sol";

import "./FoundationTreasuryNode.sol";
import "./NFT721Creator.sol";
import "./Constants.sol";

/**
 * @title Holds a reference to the Foundation Market and communicates fees to marketplaces.
 */
abstract contract NFT721Market is IGetRoyalties, IGetFees, IRoyaltyInfo, FoundationTreasuryNode, NFT721Creator {
  using AddressUpgradeable for address;

  /// @dev 10% of sales should go to the creator of the NFT.
  uint256 private constant ROYALTY_IN_BASIS_POINTS = 1000;
  /// @dev 10%, expressed as a denominator for more efficient calculations.
  uint256 private constant ROYALTY_RATIO = BASIS_POINTS / ROYALTY_IN_BASIS_POINTS;
  /// @notice The Foundation market contract address.
  address private nftMarket;

  /**
   * @notice Emitted when the market contract address used for approvals is updated.
   * @param nftMarket The new market contract address.
   */
  event NFTMarketUpdated(address indexed nftMarket);

  function _updateNFTMarket(address _nftMarket) internal {
    require(_nftMarket.isContract(), "NFT721Market: Market address is not a contract");
    nftMarket = _nftMarket;

    emit NFTMarketUpdated(_nftMarket);
  }

  /**
   * @notice Returns an array of fees in basis points.
   * The expected recipients is communicated with `getFeeRecipients`.
   * @dev The tokenId param is ignored since all NFTs return the same value.
   * @return feesInBasisPoints The array of fees to be sent to each recipient, in basis points.
   */
  function getFeeBps(
    uint256 /* id */
  ) external pure override returns (uint256[] memory) {
    uint256[] memory result = new uint256[](1);
    result[0] = ROYALTY_IN_BASIS_POINTS;
    return result;
  }

  /**
   * @notice Returns an array of recipient addresses to which fees should be sent.
   * The expected fee amount is communicated with `getFeeBps`.
   * @param tokenId The tokenId of the NFT to get the royalty recipients for.
   * @return recipients An array of addresses to which royalties should be sent.
   */
  function getFeeRecipients(uint256 tokenId) external view override returns (address payable[] memory) {
    require(_exists(tokenId), "ERC721Metadata: Query for nonexistent token");

    address payable[] memory result = new address payable[](1);
    result[0] = getTokenCreatorPaymentAddress(tokenId);
    return result;
  }

  /**
   * @notice Get fee recipients and fees in a single call.
   * @dev The data is the same as when calling getFeeRecipients and getFeeBps separately.
   * @param tokenId The tokenId of the NFT to get the royalties for.
   * @return recipients An array of addresses to which royalties should be sent.
   * @return feesInBasisPoints The array of fees to be sent to each recipient address.
   */
  function getRoyalties(uint256 tokenId)
    external
    view
    returns (address payable[] memory recipients, uint256[] memory feesInBasisPoints)
  {
    require(_exists(tokenId), "ERC721Metadata: Query for nonexistent token");
    recipients = new address payable[](1);
    recipients[0] = getTokenCreatorPaymentAddress(tokenId);
    feesInBasisPoints = new uint256[](1);
    feesInBasisPoints[0] = ROYALTY_IN_BASIS_POINTS;
  }

  /**
   * @notice Returns the address of the Foundation market contract.
   * @return market The Foundation market contract address.
   */
  function getNFTMarket() public view returns (address market) {
    market = address(nftMarket);
  }

  /**
   * @notice Returns the receiver and the amount to be sent for a secondary sale.
   * @param tokenId The tokenId of the NFT to get the royalty recipient and amount for.
   * @param salePrice The total price of the sale.
   * @return receiver The royalty recipient address for this sale.
   * @return royaltyAmount The total amount that should be sent to the `receiver`.
   */
  function royaltyInfo(uint256 tokenId, uint256 salePrice)
    external
    view
    returns (address receiver, uint256 royaltyAmount)
  {
    receiver = getTokenCreatorPaymentAddress(tokenId);
    unchecked {
      royaltyAmount = salePrice / ROYALTY_RATIO;
    }
  }

  /**
   * @inheritdoc ERC165
   * @dev Checks the supported royalty interfaces.
   */
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    if (
      interfaceId == type(IRoyaltyInfo).interfaceId ||
      interfaceId == type(IGetRoyalties).interfaceId ||
      interfaceId == type(IGetFees).interfaceId
    ) {
      return true;
    }
    return super.supportsInterface(interfaceId);
  }

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[1000] private __gap;
}
