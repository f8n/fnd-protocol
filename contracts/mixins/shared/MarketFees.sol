// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@manifoldxyz/royalty-registry-solidity/contracts/IRoyaltyRegistry.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "../../interfaces/standards/royalties/IGetFees.sol";
import "../../interfaces/standards/royalties/IGetRoyalties.sol";
import "../../interfaces/standards/royalties/IOwnable.sol";
import "../../interfaces/standards/royalties/IRoyaltyInfo.sol";
import "../../interfaces/standards/royalties/ITokenCreator.sol";

import "../../libraries/ArrayLibrary.sol";
import "../../libraries/OZERC165Checker.sol";

import "./Constants.sol";
import "./FoundationTreasuryNode.sol";
import "./SendValueWithFallbackWithdraw.sol";
import "./MarketSharedCore.sol";

error NFTMarketFees_Address_Does_Not_Support_IRoyaltyRegistry();
error NFTMarketFees_Invalid_Protocol_Fee();

/**
 * @title A mixin to distribute funds when an NFT is sold.
 * @author batu-inal & HardlyDifficult
 */
abstract contract MarketFees is FoundationTreasuryNode, MarketSharedCore, SendValueWithFallbackWithdraw {
  using AddressUpgradeable for address;
  using ArrayLibrary for address payable[];
  using ArrayLibrary for uint256[];
  using ERC165Checker for address;
  using OZERC165Checker for address;

  /**
   * @dev Removing old unused variables in an upgrade safe way. Was:
   * uint256 private _primaryFoundationFeeBasisPoints;
   * uint256 private _secondaryFoundationFeeBasisPoints;
   * uint256 private _secondaryCreatorFeeBasisPoints;
   * mapping(address => mapping(uint256 => bool)) private _nftContractToTokenIdToFirstSaleCompleted;
   */
  uint256[4] private __gap_was_fees;

  /// @notice The royalties sent to creator recipients on secondary sales.
  uint256 private constant CREATOR_ROYALTY_DENOMINATOR = BASIS_POINTS / 1_000; // 10%
  /// @notice The fee collected by Foundation for sales facilitated by this market contract.
  uint256 private immutable PROTOCOL_FEE_IN_BASIS_POINTS;
  /// @notice The fee collected by the buy referrer for sales facilitated by this market contract.
  ///         This fee is calculated from the total protocol fee.
  uint256 private constant BUY_REFERRER_FEE_DENOMINATOR = BASIS_POINTS / 100; // 1%

  IRoyaltyRegistry private immutable royaltyRegistry;

  /// @notice The address of this contract's implementation.
  /// @dev This is used when making stateless external calls to this contract,
  /// saving gas over hopping through the proxy which is only necessary when accessing state.
  MarketFees private immutable implementationAddress;

  /// @notice True for the Drop market which only performs primary sales. False if primary & secondary are supported.
  bool private immutable assumePrimarySale;

  /**
   * @notice Emitted when an NFT sold with a referrer.
   * @param nftContract The address of the NFT contract.
   * @param tokenId The id of the NFT.
   * @param buyReferrer The account which received the buy referral incentive.
   * @param buyReferrerFee The portion of the protocol fee collected by the buy referrer.
   * @param buyReferrerSellerFee The portion of the owner revenue collected by the buy referrer (not implemented).
   */
  event BuyReferralPaid(
    address indexed nftContract,
    uint256 indexed tokenId,
    address buyReferrer,
    uint256 buyReferrerFee,
    uint256 buyReferrerSellerFee
  );

  /**
   * @notice Configures the registry allowing for royalty overrides to be defined.
   * @param _royaltyRegistry The registry to use for royalty overrides.
   * @param _assumePrimarySale True for the Drop market which only performs primary sales.
   * False if primary & secondary are supported.
   */
  constructor(
    uint16 protocolFeeInBasisPoints,
    address _royaltyRegistry,
    bool _assumePrimarySale
  ) {
    if (
      protocolFeeInBasisPoints < BASIS_POINTS / BUY_REFERRER_FEE_DENOMINATOR ||
      protocolFeeInBasisPoints + BASIS_POINTS / CREATOR_ROYALTY_DENOMINATOR >= BASIS_POINTS
    ) {
      /* If the protocol fee is invalid, revert:
       * Protocol fee must be greater than the buy referrer fee since referrer fees are deducted from the protocol fee.
       * The protocol fee must leave room for the creator royalties.
       */
      revert NFTMarketFees_Invalid_Protocol_Fee();
    }
    PROTOCOL_FEE_IN_BASIS_POINTS = protocolFeeInBasisPoints;

    if (!_royaltyRegistry.supportsInterface(type(IRoyaltyRegistry).interfaceId)) {
      revert NFTMarketFees_Address_Does_Not_Support_IRoyaltyRegistry();
    }
    royaltyRegistry = IRoyaltyRegistry(_royaltyRegistry);

    assumePrimarySale = _assumePrimarySale;

    // In the constructor, `this` refers to the implementation address. Everywhere else it'll be the proxy.
    implementationAddress = this;
  }

  /**
   * @notice Distributes funds to foundation, creator recipients, and NFT owner after a sale.
   */
  function _distributeFunds(
    address nftContract,
    uint256 tokenId,
    address payable seller,
    uint256 price,
    address payable buyReferrer
  )
    internal
    returns (
      uint256 totalFees,
      uint256 creatorRev,
      uint256 sellerRev
    )
  {
    if (price == 0) {
      // When the sale price is 0, there are no revenue to distribute.
      return (0, 0, 0);
    }

    address payable[] memory creatorRecipients;
    uint256[] memory creatorShares;

    uint256 buyReferrerFee;
    (totalFees, creatorRecipients, creatorShares, sellerRev, buyReferrerFee) = _getFees(
      nftContract,
      tokenId,
      seller,
      price,
      buyReferrer
    );

    // Pay the creator(s)
    // If just a single recipient was defined, use a larger gas limit in order to support in-contract split logic.
    uint256 creatorGasLimit = creatorRecipients.length == 1
      ? SEND_VALUE_GAS_LIMIT_MULTIPLE_RECIPIENTS
      : SEND_VALUE_GAS_LIMIT_SINGLE_RECIPIENT;
    unchecked {
      for (uint256 i = 0; i < creatorRecipients.length; ++i) {
        _sendValueWithFallbackWithdraw(creatorRecipients[i], creatorShares[i], creatorGasLimit);
        // Sum the total creator rev from shares
        // creatorShares is in ETH so creatorRev will not overflow here.
        creatorRev += creatorShares[i];
      }
    }

    // Pay the seller
    _sendValueWithFallbackWithdraw(seller, sellerRev, SEND_VALUE_GAS_LIMIT_SINGLE_RECIPIENT);

    // Pay the protocol fee
    _sendValueWithFallbackWithdraw(getFoundationTreasury(), totalFees, SEND_VALUE_GAS_LIMIT_SINGLE_RECIPIENT);

    // Pay the buy referrer fee
    if (buyReferrerFee != 0) {
      _sendValueWithFallbackWithdraw(buyReferrer, buyReferrerFee, SEND_VALUE_GAS_LIMIT_SINGLE_RECIPIENT);
      emit BuyReferralPaid(nftContract, tokenId, buyReferrer, buyReferrerFee, 0);
      unchecked {
        // Add the referrer fee back into the total fees so that all 3 return fields sum to the total price for events
        totalFees += buyReferrerFee;
      }
    }
  }

  /**
   * @notice Returns how funds will be distributed for a sale at the given price point.
   * @param nftContract The address of the NFT contract.
   * @param tokenId The id of the NFT.
   * @param price The sale price to calculate the fees for.
   * @return totalFees How much will be sent to the Foundation treasury and/or referrals.
   * @return creatorRev How much will be sent across all the `creatorRecipients` defined.
   * @return creatorRecipients The addresses of the recipients to receive a portion of the creator fee.
   * @return creatorShares The percentage of the creator fee to be distributed to each `creatorRecipient`.
   * If there is only one `creatorRecipient`, this may be an empty array.
   * Otherwise `creatorShares.length` == `creatorRecipients.length`.
   * @return sellerRev How much will be sent to the owner/seller of the NFT.
   * If the NFT is being sold by the creator, this may be 0 and the full revenue will appear as `creatorRev`.
   * @return seller The address of the owner of the NFT.
   * If `sellerRev` is 0, this may be `address(0)`.
   */
  function getFeesAndRecipients(
    address nftContract,
    uint256 tokenId,
    uint256 price
  )
    external
    view
    returns (
      uint256 totalFees,
      uint256 creatorRev,
      address payable[] memory creatorRecipients,
      uint256[] memory creatorShares,
      uint256 sellerRev,
      address payable seller
    )
  {
    seller = _getSellerOrOwnerOf(nftContract, tokenId);
    (totalFees, creatorRecipients, creatorShares, sellerRev, ) = _getFees(
      nftContract,
      tokenId,
      seller,
      price,
      // Notice: Setting this value is a breaking change for the FNDMiddleware contract.
      // Will be wired in an upcoming release to communicate the buy referral information.
      payable(0)
    );

    // Sum the total creator rev from shares
    unchecked {
      for (uint256 i = 0; i < creatorShares.length; ++i) {
        creatorRev += creatorShares[i];
      }
    }
  }

  /**
   * @notice Returns the address of the registry allowing for royalty configuration overrides.
   * @dev See https://royaltyregistry.xyz/
   * @return registry The address of the royalty registry contract.
   */
  function getRoyaltyRegistry() external view returns (address registry) {
    registry = address(royaltyRegistry);
  }

  /**
   * @notice **For internal use only.**
   * @dev This function is external to allow using try/catch but is not intended for external use.
   * This checks the token creator.
   */
  function internalGetTokenCreator(address nftContract, uint256 tokenId)
    external
    view
    returns (address payable creator)
  {
    creator = ITokenCreator(nftContract).tokenCreator{ gas: READ_ONLY_GAS_LIMIT }(tokenId);
  }

  /**
   * @notice **For internal use only.**
   * @dev This function is external to allow using try/catch but is not intended for external use.
   * If ERC2981 royalties (or getRoyalties) are defined by the NFT contract, allow this standard to define immutable
   * royalties that cannot be later changed via the royalty registry.
   */
  function internalGetImmutableRoyalties(address nftContract, uint256 tokenId)
    external
    view
    returns (address payable[] memory recipients, uint256[] memory splitPerRecipientInBasisPoints)
  {
    // 1st priority: ERC-2981
    if (nftContract.supportsERC165InterfaceUnchecked(type(IRoyaltyInfo).interfaceId)) {
      try IRoyaltyInfo(nftContract).royaltyInfo{ gas: READ_ONLY_GAS_LIMIT }(tokenId, BASIS_POINTS) returns (
        address receiver,
        uint256 royaltyAmount
      ) {
        // Manifold contracts return (address(this), 0) when royalties are not defined
        // - so ignore results when the amount is 0
        if (royaltyAmount > 0) {
          recipients = new address payable[](1);
          recipients[0] = payable(receiver);
          splitPerRecipientInBasisPoints = new uint256[](1);
          // The split amount is assumed to be 100% when only 1 recipient is returned
          return (recipients, splitPerRecipientInBasisPoints);
        }
      } catch // solhint-disable-next-line no-empty-blocks
      {
        // Fall through
      }
    }

    // 2nd priority: getRoyalties
    if (nftContract.supportsERC165InterfaceUnchecked(type(IGetRoyalties).interfaceId)) {
      try IGetRoyalties(nftContract).getRoyalties{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (
        address payable[] memory _recipients,
        uint256[] memory recipientBasisPoints
      ) {
        if (_recipients.length != 0 && _recipients.length == recipientBasisPoints.length) {
          return (_recipients, recipientBasisPoints);
        }
      } catch // solhint-disable-next-line no-empty-blocks
      {
        // Fall through
      }
    }
  }

  /**
   * @notice **For internal use only.**
   * @dev This function is external to allow using try/catch but is not intended for external use.
   * This checks for royalties defined in the royalty registry or via a non-standard royalty API.
   */
  // solhint-disable-next-line code-complexity
  function internalGetMutableRoyalties(
    address nftContract,
    uint256 tokenId,
    address payable creator
  ) external view returns (address payable[] memory recipients, uint256[] memory splitPerRecipientInBasisPoints) {
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
        if (nftContract.supportsERC165InterfaceUnchecked(type(IRoyaltyInfo).interfaceId)) {
          try IRoyaltyInfo(nftContract).royaltyInfo{ gas: READ_ONLY_GAS_LIMIT }(tokenId, BASIS_POINTS) returns (
            address receiver,
            uint256 royaltyAmount
          ) {
            // Manifold contracts return (address(this), 0) when royalties are not defined
            // - so ignore results when the amount is 0
            if (royaltyAmount != 0) {
              recipients = new address payable[](1);
              recipients[0] = payable(receiver);
              splitPerRecipientInBasisPoints = new uint256[](1);
              // The split amount is assumed to be 100% when only 1 recipient is returned
              return (recipients, splitPerRecipientInBasisPoints);
            }
          } catch // solhint-disable-next-line no-empty-blocks
          {
            // Fall through
          }
        }

        // 4th priority: getRoyalties override
        if (recipients.length == 0 && nftContract.supportsERC165InterfaceUnchecked(type(IGetRoyalties).interfaceId)) {
          try IGetRoyalties(nftContract).getRoyalties{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (
            address payable[] memory _recipients,
            uint256[] memory recipientBasisPoints
          ) {
            if (_recipients.length != 0 && _recipients.length == recipientBasisPoints.length) {
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
    if (nftContract.supportsERC165InterfaceUnchecked(type(IGetFees).interfaceId)) {
      try IGetFees(nftContract).getFeeRecipients{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (
        address payable[] memory _recipients
      ) {
        if (_recipients.length != 0) {
          try IGetFees(nftContract).getFeeBps{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (
            uint256[] memory recipientBasisPoints
          ) {
            if (_recipients.length == recipientBasisPoints.length) {
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
    if (creator != address(0)) {
      // Only pay the tokenCreator if there wasn't another royalty defined
      recipients = new address payable[](1);
      recipients[0] = creator;
      splitPerRecipientInBasisPoints = new uint256[](1);
      // The split amount is assumed to be 100% when only 1 recipient is returned
      return (recipients, splitPerRecipientInBasisPoints);
    }

    // 7th priority: owner from contract or override
    try IOwnable(nftContract).owner{ gas: READ_ONLY_GAS_LIMIT }() returns (address owner) {
      if (owner != address(0)) {
        // Only pay the owner if there wasn't another royalty defined
        recipients = new address payable[](1);
        recipients[0] = payable(owner);
        splitPerRecipientInBasisPoints = new uint256[](1);
        // The split amount is assumed to be 100% when only 1 recipient is returned
        return (recipients, splitPerRecipientInBasisPoints);
      }
    } catch // solhint-disable-next-line no-empty-blocks
    {
      // Fall through
    }

    // If no valid payment address or creator is found, return 0 recipients
  }

  /**
   * @notice Calculates how funds should be distributed for the given sale details.
   * @dev When the NFT is being sold by the `tokenCreator`, all the seller revenue will
   * be split with the royalty recipients defined for that NFT.
   */
  // solhint-disable-next-line code-complexity
  function _getFees(
    address nftContract,
    uint256 tokenId,
    address payable seller,
    uint256 price,
    address payable buyReferrer
  )
    private
    view
    returns (
      uint256 totalFees,
      address payable[] memory creatorRecipients,
      uint256[] memory creatorShares,
      uint256 sellerRev,
      uint256 buyReferrerFee
    )
  {
    // Calculate the protocol fee
    totalFees = (price * PROTOCOL_FEE_IN_BASIS_POINTS) / BASIS_POINTS;

    address payable creator;
    try implementationAddress.internalGetTokenCreator(nftContract, tokenId) returns (address payable _creator) {
      creator = _creator;
    } catch // solhint-disable-next-line no-empty-blocks
    {
      // Fall through
    }

    try implementationAddress.internalGetImmutableRoyalties(nftContract, tokenId) returns (
      address payable[] memory _recipients,
      uint256[] memory _splitPerRecipientInBasisPoints
    ) {
      (creatorRecipients, creatorShares) = (_recipients, _splitPerRecipientInBasisPoints);
    } catch // solhint-disable-next-line no-empty-blocks
    {
      // Fall through
    }

    if (creatorRecipients.length == 0) {
      // Check mutable royalties only if we didn't find results from the immutable API
      try implementationAddress.internalGetMutableRoyalties(nftContract, tokenId, creator) returns (
        address payable[] memory _recipients,
        uint256[] memory _splitPerRecipientInBasisPoints
      ) {
        (creatorRecipients, creatorShares) = (_recipients, _splitPerRecipientInBasisPoints);
      } catch // solhint-disable-next-line no-empty-blocks
      {
        // Fall through
      }
    }

    if (creatorRecipients.length != 0 || assumePrimarySale) {
      uint256 creatorRev;
      if (assumePrimarySale) {
        // All revenue should go to the creator recipients
        unchecked {
          // totalFees is always < price.
          creatorRev = price - totalFees;
        }
        if (creatorRecipients.length == 0) {
          // If no creators were found via the royalty APIs, then set that recipient to the seller's address
          creatorRecipients = new address payable[](1);
          creatorRecipients[0] = seller;
          creatorShares = new uint256[](1);
          // The split amount is assumed to be 100% when only 1 recipient is returned
        }
      } else if (seller == creator || (creatorRecipients.length != 0 && seller == creatorRecipients[0])) {
        // When sold by the creator, all revenue is split if applicable.
        unchecked {
          // totalFees is always < price.
          creatorRev = price - totalFees;
        }
      } else {
        // Rounding favors the owner first, then creator, and foundation last.
        unchecked {
          // Safe math is not required when dividing by a non-zero constant.
          creatorRev = price / CREATOR_ROYALTY_DENOMINATOR;
        }
        sellerRev = price - totalFees - creatorRev;
      }

      // Cap the max number of recipients supported
      creatorRecipients.capLength(MAX_ROYALTY_RECIPIENTS);
      creatorShares.capLength(MAX_ROYALTY_RECIPIENTS);

      // Sum the total shares defined
      uint256 totalShares;
      if (creatorRecipients.length > 1) {
        unchecked {
          for (uint256 i = 0; i < creatorRecipients.length; ++i) {
            if (creatorRecipients[i] == seller) {
              // If the seller is any of the recipients defined, assume a primary sale
              creatorRev += sellerRev;
              sellerRev = 0;
            }
            if (creatorShares[i] > BASIS_POINTS) {
              // If the numbers are >100% we ignore the fee recipients and pay just the first instead
              totalShares = 0;
              break;
            }
            totalShares += creatorShares[i];
          }
        }

        if (totalShares == 0) {
          // If no shares were defined or shares were out of bounds, pay only the first recipient
          creatorRecipients.capLength(1);
          creatorShares.capLength(1);
        }
      }

      // Send payouts to each additional recipient if more than 1 was defined
      uint256 totalRoyaltiesDistributed;
      for (uint256 i = 1; i < creatorRecipients.length; ) {
        uint256 royalty = (creatorRev * creatorShares[i]) / totalShares;
        totalRoyaltiesDistributed += royalty;
        creatorShares[i] = royalty;
        unchecked {
          ++i;
        }
      }

      // Send the remainder to the 1st creator, rounding in their favor
      creatorShares[0] = creatorRev - totalRoyaltiesDistributed;
    } else {
      // No royalty recipients found.
      unchecked {
        // totalFees is always < price.
        sellerRev = price - totalFees;
      }
    }

    if (buyReferrer != address(0) && buyReferrer != msg.sender && buyReferrer != seller && buyReferrer != creator) {
      unchecked {
        buyReferrerFee = price / BUY_REFERRER_FEE_DENOMINATOR;

        // buyReferrerFee is always <= totalFees
        totalFees -= buyReferrerFee;
      }
    }
  }

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[1_000] private __gap;
}
