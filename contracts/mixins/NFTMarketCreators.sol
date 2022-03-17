// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "./OZ/ERC165Checker.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./Constants.sol";

import "../interfaces/IGetFees.sol";
import "../interfaces/IGetRoyalties.sol";
import "../interfaces/IOwnable.sol";
import "../interfaces/IRoyaltyInfo.sol";
import "../interfaces/ITokenCreator.sol";
import "@manifoldxyz/royalty-registry-solidity/contracts/IRoyaltyRegistry.sol";

error NFTMarketCreators_Address_Does_Not_Support_IRoyaltyRegistry();

/**
 * @title A mixin for associating creators to NFTs.
 * @dev In the future this may store creators directly in order to support NFTs created on a different platform.
 */
abstract contract NFTMarketCreators is
  Constants,
  ReentrancyGuardUpgradeable // Adding this unused mixin to help with linearization
{
  using ERC165Checker for address;

  IRoyaltyRegistry private immutable royaltyRegistry;

  /**
   * @notice Configures the registry allowing for royalty overrides to be defined.
   * @param _royaltyRegistry The registry to use for royalty overrides.
   */
  constructor(address _royaltyRegistry) {
    if (!_royaltyRegistry.supportsInterface(type(IRoyaltyRegistry).interfaceId)) {
      revert NFTMarketCreators_Address_Does_Not_Support_IRoyaltyRegistry();
    }
    royaltyRegistry = IRoyaltyRegistry(_royaltyRegistry);
  }

  /**
   * @notice Looks up the royalty payment configuration for a given NFT.
   * If more than 5 royalty recipients are defined, only the first 5 are sent royalties - the others are ignored.
   * The percents distributed will always be normalized to exactly 10%, when multiple recipients are defined
   * we use the values returned to determine how much of that 10% each recipient should get.
   * @dev This will check various royalty APIs on the NFT and the royalty override
   * if one was registered with the royalty registry. This aims to send royalties
   * in the manner requested by the NFT owner, regardless of where the NFT was minted.
   */
  // solhint-disable-next-line code-complexity
  function _getCreatorPaymentInfo(address nftContract, uint256 tokenId)
    internal
    view
    returns (address payable[] memory recipients, uint256[] memory splitPerRecipientInBasisPoints)
  {
    // All NFTs implement 165 so we skip that check, individual interfaces should return false if 165 is not implemented

    // 1st priority: ERC-2981
    if (nftContract.supportsERC165Interface(type(IRoyaltyInfo).interfaceId)) {
      try IRoyaltyInfo(nftContract).royaltyInfo{ gas: READ_ONLY_GAS_LIMIT }(tokenId, BASIS_POINTS) returns (
        address receiver,
        uint256 royaltyAmount
      ) {
        // Manifold contracts return (address(this), 0) when royalties are not defined
        // - so ignore results when the amount is 0
        if (royaltyAmount > 0) {
          recipients = new address payable[](1);
          recipients[0] = payable(receiver);
          // splitPerRecipientInBasisPoints is not relevant when only 1 recipient is defined
          return (recipients, splitPerRecipientInBasisPoints);
        }
      } catch // solhint-disable-next-line no-empty-blocks
      {
        // Fall through
      }
    }

    // 2nd priority: getRoyalties
    if (nftContract.supportsERC165Interface(type(IGetRoyalties).interfaceId)) {
      try IGetRoyalties(nftContract).getRoyalties{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (
        address payable[] memory _recipients,
        uint256[] memory recipientBasisPoints
      ) {
        uint256 recipientLen = _recipients.length;
        if (recipientLen != 0 && recipientLen == recipientBasisPoints.length) {
          return (_recipients, recipientBasisPoints);
        }
      } catch // solhint-disable-next-line no-empty-blocks
      {
        // Fall through
      }
    }

    /* Overrides must support ERC-165 when registered, except for overrides defined by the registry owner.
       If that results in an override w/o 165 we may need to upgrade the market to support or ignore that override. */
    // The registry requires overrides are not 0 and contracts when set.
    // If no override is set, the nftContract address is returned.

    try royaltyRegistry.getRoyaltyLookupAddress{ gas: READ_ONLY_GAS_LIMIT }(nftContract) returns (
      address overrideContract
    ) {
      if (overrideContract != nftContract) {
        nftContract = overrideContract;

        // The functions above are repeated here if an override is set.

        // 3rd priority: ERC-2981 override
        if (nftContract.supportsERC165Interface(type(IRoyaltyInfo).interfaceId)) {
          try IRoyaltyInfo(nftContract).royaltyInfo{ gas: READ_ONLY_GAS_LIMIT }(tokenId, BASIS_POINTS) returns (
            address receiver,
            uint256 /* royaltyAmount */
          ) {
            recipients = new address payable[](1);
            recipients[0] = payable(receiver);
            // splitPerRecipientInBasisPoints is not relevant when only 1 recipient is defined
            return (recipients, splitPerRecipientInBasisPoints);
          } catch // solhint-disable-next-line no-empty-blocks
          {
            // Fall through
          }
        }

        // 4th priority: getRoyalties override
        if (recipients.length == 0 && nftContract.supportsERC165Interface(type(IGetRoyalties).interfaceId)) {
          try IGetRoyalties(nftContract).getRoyalties{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (
            address payable[] memory _recipients,
            uint256[] memory recipientBasisPoints
          ) {
            uint256 recipientLen = _recipients.length;
            if (recipientLen != 0 && recipientLen == recipientBasisPoints.length) {
              return (_recipients, recipientBasisPoints);
            }
          } catch // solhint-disable-next-line no-empty-blocks
          {
            // Fall through
          }
        }
      }
    } catch // solhint-disable-next-line no-empty-blocks
    {
      // Ignore out of gas errors and continue using the nftContract address
    }

    // 5th priority: getFee* from contract or override
    if (nftContract.supportsERC165Interface(type(IGetFees).interfaceId)) {
      try IGetFees(nftContract).getFeeRecipients{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (
        address payable[] memory _recipients
      ) {
        uint256 recipientLen = _recipients.length;
        if (recipientLen != 0) {
          try IGetFees(nftContract).getFeeBps{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (
            uint256[] memory recipientBasisPoints
          ) {
            if (recipientLen == recipientBasisPoints.length) {
              return (_recipients, recipientBasisPoints);
            }
          } catch // solhint-disable-next-line no-empty-blocks
          {
            // Fall through
          }
        }
      } catch // solhint-disable-next-line no-empty-blocks
      {
        // Fall through
      }
    }

    // 6th priority: tokenCreator w/ or w/o requiring 165 from contract or override
    try ITokenCreator(nftContract).tokenCreator{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (
      address payable _creator
    ) {
      // Only pay the tokenCreator if there wasn't another royalty defined
      recipients = new address payable[](1);
      recipients[0] = _creator;
      // splitPerRecipientInBasisPoints is not relevant when only 1 recipient is defined
      return (recipients, splitPerRecipientInBasisPoints);
    } catch // solhint-disable-next-line no-empty-blocks
    {
      // Fall through
    }

    // 7th priority: owner from contract or override
    try IOwnable(nftContract).owner{ gas: READ_ONLY_GAS_LIMIT }() returns (address owner) {
      // Only pay the owner if there wasn't another royalty defined
      recipients = new address payable[](1);
      recipients[0] = payable(owner);
      // splitPerRecipientInBasisPoints is not relevant when only 1 recipient is defined
      return (recipients, splitPerRecipientInBasisPoints);
    } catch // solhint-disable-next-line no-empty-blocks
    {
      // Fall through
    }

    // If no valid payment address or creator is found, return 0 recipients
  }

  /**
   * @notice Returns the address of the registry allowing for royalty configuration overrides.
   * @return registry The address of the royalty registry contract.
   */
  function getRoyaltyRegistry() public view returns (address registry) {
    return address(royaltyRegistry);
  }

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   * @dev 500 slots were consumed with the addition of `SendValueWithFallbackWithdraw`.
   */
  uint256[500] private __gap;
}
