// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "./NFTMarketAuction.sol";
import "./NFTMarketFees.sol";

/// @param auctionId The already listed auctionId for this NFT.
error NFTMarketReserveAuction_Already_Listed(uint256 auctionId);
/// @param minAmount The minimum amount that must be bid in order for it to be accepted.
error NFTMarketReserveAuction_Bid_Must_Be_At_Least_Min_Amount(uint256 minAmount);
error NFTMarketReserveAuction_Cannot_Admin_Cancel_Without_Reason();
/// @param reservePrice The current reserve price.
error NFTMarketReserveAuction_Cannot_Bid_Lower_Than_Reserve_Price(uint256 reservePrice);
/// @param endTime The timestamp at which the auction had ended.
error NFTMarketReserveAuction_Cannot_Bid_On_Ended_Auction(uint256 endTime);
error NFTMarketReserveAuction_Cannot_Bid_On_Nonexistent_Auction();
error NFTMarketReserveAuction_Cannot_Cancel_Nonexistent_Auction();
error NFTMarketReserveAuction_Cannot_Finalize_Already_Settled_Auction();
/// @param endTime The timestamp at which the auction will end.
error NFTMarketReserveAuction_Cannot_Finalize_Auction_In_Progress(uint256 endTime);
error NFTMarketReserveAuction_Cannot_Rebid_Over_Outstanding_Bid();
error NFTMarketReserveAuction_Cannot_Update_Auction_In_Progress();
/// @param maxDuration The maximum configuration for a duration of the auction, in seconds.
error NFTMarketReserveAuction_Exceeds_Max_Duration(uint256 maxDuration);
/// @param extensionDuration The extension duration, in seconds.
error NFTMarketReserveAuction_Less_Than_Extension_Duration(uint256 extensionDuration);
error NFTMarketReserveAuction_Must_Set_Non_Zero_Reserve_Price();
/// @param seller The current owner of the NFT.
error NFTMarketReserveAuction_Not_Matching_Seller(address seller);
/// @param owner The current owner of the NFT.
error NFTMarketReserveAuction_Only_Owner_Can_Update_Auction(address owner);
error NFTMarketReserveAuction_Price_Already_Set();
error NFTMarketReserveAuction_Too_Much_Value_Provided();

/**
 * @title Allows the owner of an NFT to list it in auction.
 * @notice NFTs in auction are escrowed in the market contract.
 * @dev There is room to optimize the storage for auctions, significantly reducing gas costs.
 * This may be done in the future, but for now it will remain as is in order to ease upgrade compatibility.
 */
abstract contract NFTMarketReserveAuction is NFTMarketFees, NFTMarketAuction {
  /// @notice The auction configuration for a specific NFT.
  struct ReserveAuction {
    /// @notice The address of the NFT contract.
    address nftContract;
    /// @notice The id of the NFT.
    uint256 tokenId;
    /// @notice The owner of the NFT which listed it in auction.
    address payable seller;
    /// @notice The duration for this auction.
    uint256 duration;
    /// @notice The extension window for this auction.
    uint256 extensionDuration;
    /// @notice The time at which this auction will not accept any new bids.
    /// @dev This is `0` until the first bid is placed.
    uint256 endTime;
    /// @notice The current highest bidder in this auction.
    /// @dev This is `address(0)` until the first bid is placed.
    address payable bidder;
    /// @notice The latest price of the NFT in this auction.
    /// @dev This is set to the reserve price, and then to the highest bid once the auction has started.
    uint256 amount;
  }

  /// @notice Stores the auction configuration for a specific NFT.
  /// @dev This allows us to modify the storage struct without changing external APIs.
  struct ReserveAuctionStorage {
    /// @notice The address of the NFT contract.
    address nftContract;
    /// @notice The id of the NFT.
    uint256 tokenId;
    /// @notice The owner of the NFT which listed it in auction.
    address payable seller;
    /// @notice First slot (of 12B) used for the bidReferrerAddress.
    /// The bidReferrerAddress is the address used to pay the referrer on finalize.
    /// @dev This approach is used in order to pack storage, saving gas.
    uint96 bidReferrerAddressSlot0;
    /// @dev This field is no longer used.
    uint256 __gap_was_duration;
    /// @dev This field is no longer used.
    uint256 __gap_was_extensionDuration;
    /// @notice The time at which this auction will not accept any new bids.
    /// @dev This is `0` until the first bid is placed.
    uint256 endTime;
    /// @notice The current highest bidder in this auction.
    /// @dev This is `address(0)` until the first bid is placed.
    address payable bidder;
    /// @notice Second slot (of 8B) used for the bidReferrerAddress.
    uint64 bidReferrerAddressSlot1;
    /// @notice The latest price of the NFT in this auction.
    /// @dev This is set to the reserve price, and then to the highest bid once the auction has started.
    uint256 amount;
  }

  /// @notice The auction configuration for a specific auction id.
  mapping(address => mapping(uint256 => uint256)) private nftContractToTokenIdToAuctionId;
  /// @notice The auction id for a specific NFT.
  /// @dev This is deleted when an auction is finalized or canceled.
  mapping(uint256 => ReserveAuctionStorage) private auctionIdToAuction;

  /**
   * @dev Removing old unused variables in an upgrade safe way. Was:
   * uint256 private __gap_was_minPercentIncrementInBasisPoints;
   * uint256 private __gap_was_maxBidIncrementRequirement;
   * uint256 private __gap_was_duration;
   * uint256 private __gap_was_extensionDuration;
   * uint256 private __gap_was_goLiveDate;
   */
  uint256[5] private __gap_was_config;

  /// @notice How long an auction lasts for once the first bid has been received.
  uint256 private immutable DURATION;

  /// @notice The window for auction extensions, any bid placed in the final 15 minutes
  /// of an auction will reset the time remaining to 15 minutes.
  uint256 private constant EXTENSION_DURATION = 15 minutes;

  /// @notice Caps the max duration that may be configured so that overflows will not occur.
  uint256 private constant MAX_MAX_DURATION = 1000 days;

  /**
   * @notice Emitted when a bid is placed.
   * @param auctionId The id of the auction this bid was for.
   * @param bidder The address of the bidder.
   * @param amount The amount of the bid.
   * @param endTime The new end time of the auction (which may have been set or extended by this bid).
   */
  event ReserveAuctionBidPlaced(uint256 indexed auctionId, address indexed bidder, uint256 amount, uint256 endTime);
  /**
   * @notice Emitted when an auction is cancelled.
   * @dev This is only possible if the auction has not received any bids.
   * @param auctionId The id of the auction that was cancelled.
   */
  event ReserveAuctionCanceled(uint256 indexed auctionId);
  /**
   * @notice Emitted when an auction is canceled by a Foundation admin.
   * @dev When this occurs, the highest bidder (if there was a bid) is automatically refunded.
   * @param auctionId The id of the auction that was cancelled.
   * @param reason The reason for the cancellation.
   */
  event ReserveAuctionCanceledByAdmin(uint256 indexed auctionId, string reason);
  /**
   * @notice Emitted when an NFT is listed for auction.
   * @param seller The address of the seller.
   * @param nftContract The address of the NFT contract.
   * @param tokenId The id of the NFT.
   * @param duration The duration of the auction (always 24-hours).
   * @param extensionDuration The duration of the auction extension window (always 15-minutes).
   * @param reservePrice The reserve price to kick off the auction.
   * @param auctionId The id of the auction that was created.
   */
  event ReserveAuctionCreated(
    address indexed seller,
    address indexed nftContract,
    uint256 indexed tokenId,
    uint256 duration,
    uint256 extensionDuration,
    uint256 reservePrice,
    uint256 auctionId
  );
  /**
   * @notice Emitted when an auction that has already ended is finalized,
   * indicating that the NFT has been transferred and revenue from the sale distributed.
   * @dev The amount of the highest bid / final sale price for this auction
   * is `protocolFee` + `creatorFee` + `sellerRev`.
   * @param auctionId The id of the auction that was finalized.
   * @param seller The address of the seller.
   * @param bidder The address of the highest bidder that won the NFT.
   * @param protocolFee The amount of ETH that was sent to Foundation for this sale.
   * @param creatorFee The amount of ETH that was sent to the creator for this sale.
   * @param sellerRev The amount of ETH that was sent to the owner for this sale.
   */
  event ReserveAuctionFinalized(
    uint256 indexed auctionId,
    address indexed seller,
    address indexed bidder,
    uint256 protocolFee,
    uint256 creatorFee,
    uint256 sellerRev
  );
  /**
   * @notice Emitted when an auction is invalidated due to other market activity.
   * @dev This occurs when the NFT is sold another way, such as with `buy` or `acceptOffer`.
   * @param auctionId The id of the auction that was invalidated.
   */
  event ReserveAuctionInvalidated(uint256 indexed auctionId);
  /**
   * @notice Emitted when the auction's reserve price is changed.
   * @dev This is only possible if the auction has not received any bids.
   * @param auctionId The id of the auction that was updated.
   * @param reservePrice The new reserve price for the auction.
   */
  event ReserveAuctionUpdated(uint256 indexed auctionId, uint256 reservePrice);

  /// @notice Confirms that the reserve price is not zero.
  modifier onlyValidAuctionConfig(uint256 reservePrice) {
    if (reservePrice == 0) {
      revert NFTMarketReserveAuction_Must_Set_Non_Zero_Reserve_Price();
    }
    _;
  }

  /**
   * @notice Configures the duration for auctions.
   * @param duration The duration for auctions, in seconds.
   */
  constructor(uint256 duration) {
    if (duration > MAX_MAX_DURATION) {
      // This ensures that math in this file will not overflow due to a huge duration.
      revert NFTMarketReserveAuction_Exceeds_Max_Duration(MAX_MAX_DURATION);
    }
    if (duration < EXTENSION_DURATION) {
      // The auction duration configuration must be greater than the extension window of 15 minutes
      revert NFTMarketReserveAuction_Less_Than_Extension_Duration(EXTENSION_DURATION);
    }
    DURATION = duration;
  }

  /**
   * @notice Allows Foundation to cancel an auction, refunding the bidder and returning the NFT to
   * the seller (if not active buy price set).
   * This should only be used for extreme cases such as DMCA takedown requests.
   * @param auctionId The id of the auction to cancel.
   * @param reason The reason for the cancellation (a required field).
   */
  function adminCancelReserveAuction(uint256 auctionId, string calldata reason)
    external
    onlyFoundationAdmin
    nonReentrant
  {
    if (bytes(reason).length == 0) {
      revert NFTMarketReserveAuction_Cannot_Admin_Cancel_Without_Reason();
    }
    ReserveAuctionStorage memory auction = auctionIdToAuction[auctionId];
    if (auction.amount == 0) {
      revert NFTMarketReserveAuction_Cannot_Cancel_Nonexistent_Auction();
    }

    delete nftContractToTokenIdToAuctionId[auction.nftContract][auction.tokenId];
    delete auctionIdToAuction[auctionId];

    // Return the NFT to the owner.
    _transferFromEscrowIfAvailable(auction.nftContract, auction.tokenId, auction.seller);

    if (auction.bidder != address(0)) {
      // Refund the highest bidder if any bids were placed in this auction.
      _sendValueWithFallbackWithdraw(auction.bidder, auction.amount, SEND_VALUE_GAS_LIMIT_SINGLE_RECIPIENT);
    }

    emit ReserveAuctionCanceledByAdmin(auctionId, reason);
  }

  /**
   * @notice If an auction has been created but has not yet received bids, it may be canceled by the seller.
   * @dev The NFT is transferred back to the owner unless there is still a buy price set.
   * @param auctionId The id of the auction to cancel.
   */
  function cancelReserveAuction(uint256 auctionId) external nonReentrant {
    ReserveAuctionStorage memory auction = auctionIdToAuction[auctionId];
    if (auction.seller != msg.sender) {
      revert NFTMarketReserveAuction_Only_Owner_Can_Update_Auction(auction.seller);
    }
    if (auction.endTime != 0) {
      revert NFTMarketReserveAuction_Cannot_Update_Auction_In_Progress();
    }

    // Remove the auction.
    delete nftContractToTokenIdToAuctionId[auction.nftContract][auction.tokenId];
    delete auctionIdToAuction[auctionId];

    // Transfer the NFT unless it still has a buy price set.
    _transferFromEscrowIfAvailable(auction.nftContract, auction.tokenId, auction.seller);

    emit ReserveAuctionCanceled(auctionId);
  }

  /**
   * @notice Creates an auction for the given NFT.
   * The NFT is held in escrow until the auction is finalized or canceled.
   * @param nftContract The address of the NFT contract.
   * @param tokenId The id of the NFT.
   * @param reservePrice The initial reserve price for the auction.
   */
  function createReserveAuction(
    address nftContract,
    uint256 tokenId,
    uint256 reservePrice
  ) external nonReentrant onlyValidAuctionConfig(reservePrice) {
    uint256 auctionId = _getNextAndIncrementAuctionId();

    // If the `msg.sender` is not the owner of the NFT, transferring into escrow should fail.
    _transferToEscrow(nftContract, tokenId);

    // This check must be after _transferToEscrow in case auto-settle was required
    if (nftContractToTokenIdToAuctionId[nftContract][tokenId] != 0) {
      revert NFTMarketReserveAuction_Already_Listed(nftContractToTokenIdToAuctionId[nftContract][tokenId]);
    }

    // Store the auction details
    nftContractToTokenIdToAuctionId[nftContract][tokenId] = auctionId;
    ReserveAuctionStorage storage auction = auctionIdToAuction[auctionId];
    auction.nftContract = nftContract;
    auction.tokenId = tokenId;
    auction.seller = payable(msg.sender);
    auction.amount = reservePrice;

    emit ReserveAuctionCreated(msg.sender, nftContract, tokenId, DURATION, EXTENSION_DURATION, reservePrice, auctionId);
  }

  /**
   * @notice Once the countdown has expired for an auction, anyone can settle the auction.
   * This will send the NFT to the highest bidder and distribute revenue for this sale.
   * @param auctionId The id of the auction to settle.
   */
  function finalizeReserveAuction(uint256 auctionId) external nonReentrant {
    if (auctionIdToAuction[auctionId].endTime == 0) {
      revert NFTMarketReserveAuction_Cannot_Finalize_Already_Settled_Auction();
    }
    _finalizeReserveAuction({ auctionId: auctionId, keepInEscrow: false });
  }

  /**
   * @notice Place a bid in an auction.
   * A bidder may place a bid which is at least the value defined by `getMinBidAmount`.
   * If this is the first bid on the auction, the countdown will begin.
   * If there is already an outstanding bid, the previous bidder will be refunded at this time
   * and if the bid is placed in the final moments of the auction, the countdown may be extended.
   * @dev This API is deprecated and will be removed in the future, `placeBidV2` should be used instead.
   * @param auctionId The id of the auction to bid on.
   */
  function placeBid(uint256 auctionId) external payable {
    placeBidV2(auctionId, msg.value, payable(0));
  }

  /**
   * @notice Place a bid in an auction.
   * A bidder may place a bid which is at least the amount defined by `getMinBidAmount`.
   * If this is the first bid on the auction, the countdown will begin.
   * If there is already an outstanding bid, the previous bidder will be refunded at this time
   * and if the bid is placed in the final moments of the auction, the countdown may be extended.
   * @dev `amount` - `msg.value` is withdrawn from the bidder's FETH balance.
   * @param auctionId The id of the auction to bid on.
   * @param amount The amount to bid, if this is more than `msg.value` funds will be withdrawn from your FETH balance.
   */
  /* solhint-disable-next-line code-complexity */
  function placeBidV2(
    uint256 auctionId,
    uint256 amount,
    address payable referrer
  ) public payable nonReentrant {
    ReserveAuctionStorage storage auction = auctionIdToAuction[auctionId];

    if (auction.amount == 0) {
      // No auction found
      revert NFTMarketReserveAuction_Cannot_Bid_On_Nonexistent_Auction();
    } else if (amount < msg.value) {
      // The amount is specified by the bidder, so if too much ETH is sent then something went wrong.
      revert NFTMarketReserveAuction_Too_Much_Value_Provided();
    }

    uint256 endTime = auction.endTime;

    // Store the bid referral
    if (referrer != address(0) || endTime != 0) {
      auction.bidReferrerAddressSlot0 = uint96(uint160(address(referrer)) >> 64);
      auction.bidReferrerAddressSlot1 = uint64(uint160(address(referrer)));
    }

    if (endTime == 0) {
      // This is the first bid, kicking off the auction.

      if (amount < auction.amount) {
        // The bid must be >= the reserve price.
        revert NFTMarketReserveAuction_Cannot_Bid_Lower_Than_Reserve_Price(auction.amount);
      }

      // Notify other market tools that an auction for this NFT has been kicked off.
      // The only state change before this call is potentially withdrawing funds from FETH.
      _beforeAuctionStarted(auction.nftContract, auction.tokenId);

      // Store the bid details.
      auction.amount = amount;
      auction.bidder = payable(msg.sender);

      // On the first bid, set the endTime to now + duration.
      unchecked {
        // Duration is always set to 24hrs so the below can't overflow.
        endTime = block.timestamp + DURATION;
      }
      auction.endTime = endTime;
    } else {
      if (endTime < block.timestamp) {
        // The auction has already ended.
        revert NFTMarketReserveAuction_Cannot_Bid_On_Ended_Auction(endTime);
      } else if (auction.bidder == msg.sender) {
        // We currently do not allow a bidder to increase their bid unless another user has outbid them first.
        revert NFTMarketReserveAuction_Cannot_Rebid_Over_Outstanding_Bid();
      } else {
        uint256 minIncrement = _getMinIncrement(auction.amount);
        if (amount < minIncrement) {
          // If this bid outbids another, it must be at least 10% greater than the last bid.
          revert NFTMarketReserveAuction_Bid_Must_Be_At_Least_Min_Amount(minIncrement);
        }
      }

      // Cache and update bidder state
      uint256 originalAmount = auction.amount;
      address payable originalBidder = auction.bidder;
      auction.amount = amount;
      auction.bidder = payable(msg.sender);

      unchecked {
        // When a bid outbids another, check to see if a time extension should apply.
        // We confirmed that the auction has not ended, so endTime is always >= the current timestamp.
        // Current time plus extension duration (always 15 mins) cannot overflow.
        uint256 endTimeWithExtension = block.timestamp + EXTENSION_DURATION;
        if (endTime < endTimeWithExtension) {
          endTime = endTimeWithExtension;
          auction.endTime = endTime;
        }
      }

      // Refund the previous bidder
      _sendValueWithFallbackWithdraw(originalBidder, originalAmount, SEND_VALUE_GAS_LIMIT_SINGLE_RECIPIENT);
    }

    // Withdraw last in order to leverage freed FETH balance.
    if (amount > msg.value) {
      // Withdraw additional ETH required from their available FETH balance.

      unchecked {
        // The if above ensures delta will not underflow.
        // Withdraw ETH from the buyer's account in the FETH token contract.
        feth.marketWithdrawFrom(msg.sender, amount - msg.value);
      }
    }

    emit ReserveAuctionBidPlaced(auctionId, msg.sender, amount, endTime);
  }

  /**
   * @notice If an auction has been created but has not yet received bids, the reservePrice may be
   * changed by the seller.
   * @param auctionId The id of the auction to change.
   * @param reservePrice The new reserve price for this auction.
   */
  function updateReserveAuction(uint256 auctionId, uint256 reservePrice) external onlyValidAuctionConfig(reservePrice) {
    ReserveAuctionStorage storage auction = auctionIdToAuction[auctionId];
    if (auction.seller != msg.sender) {
      revert NFTMarketReserveAuction_Only_Owner_Can_Update_Auction(auction.seller);
    } else if (auction.endTime != 0) {
      revert NFTMarketReserveAuction_Cannot_Update_Auction_In_Progress();
    } else if (auction.amount == reservePrice) {
      revert NFTMarketReserveAuction_Price_Already_Set();
    }

    // Update the current reserve price.
    auction.amount = reservePrice;

    emit ReserveAuctionUpdated(auctionId, reservePrice);
  }

  /**
   * @notice Settle an auction that has already ended.
   * This will send the NFT to the highest bidder and distribute revenue for this sale.
   * @param keepInEscrow If true, the NFT will be kept in escrow to save gas by avoiding
   * redundant transfers if the NFT should remain in escrow, such as when the new owner
   * sets a buy price or lists it in a new auction.
   */
  function _finalizeReserveAuction(uint256 auctionId, bool keepInEscrow) private {
    ReserveAuctionStorage memory auction = auctionIdToAuction[auctionId];

    if (auction.endTime >= block.timestamp) {
      revert NFTMarketReserveAuction_Cannot_Finalize_Auction_In_Progress(auction.endTime);
    }

    // Remove the auction.
    delete nftContractToTokenIdToAuctionId[auction.nftContract][auction.tokenId];
    delete auctionIdToAuction[auctionId];

    if (!keepInEscrow) {
      // The seller was authorized when the auction was originally created
      super._transferFromEscrow(auction.nftContract, auction.tokenId, auction.bidder, address(0));
    }

    // Distribute revenue for this sale.
    (uint256 protocolFee, uint256 creatorFee, uint256 sellerRev) = _distributeFunds(
      auction.nftContract,
      auction.tokenId,
      auction.seller,
      auction.amount,
      payable(address((uint160(auction.bidReferrerAddressSlot0) << 64) | uint160(auction.bidReferrerAddressSlot1)))
    );

    emit ReserveAuctionFinalized(auctionId, auction.seller, auction.bidder, protocolFee, creatorFee, sellerRev);
  }

  /**
   * @inheritdoc NFTMarketCore
   * @dev If an auction is found:
   *  - If the auction is over, it will settle the auction and confirm the new seller won the auction.
   *  - If the auction has not received a bid, it will invalidate the auction.
   *  - If the auction is in progress, this will revert.
   */
  function _transferFromEscrow(
    address nftContract,
    uint256 tokenId,
    address recipient,
    address authorizeSeller
  ) internal virtual override {
    uint256 auctionId = nftContractToTokenIdToAuctionId[nftContract][tokenId];
    if (auctionId != 0) {
      ReserveAuctionStorage storage auction = auctionIdToAuction[auctionId];
      if (auction.endTime == 0) {
        // The auction has not received any bids yet so it may be invalided.

        if (authorizeSeller != address(0) && auction.seller != authorizeSeller) {
          // The account trying to transfer the NFT is not the current owner.
          revert NFTMarketReserveAuction_Not_Matching_Seller(auction.seller);
        }

        // Remove the auction.
        delete nftContractToTokenIdToAuctionId[nftContract][tokenId];
        delete auctionIdToAuction[auctionId];

        emit ReserveAuctionInvalidated(auctionId);
      } else {
        // If the auction has ended, the highest bidder will be the new owner
        // and if the auction is in progress, this will revert.

        // `authorizeSeller != address(0)` does not apply here since an unsettled auction must go
        // through this path to know who the authorized seller should be.
        if (auction.bidder != authorizeSeller) {
          revert NFTMarketReserveAuction_Not_Matching_Seller(auction.bidder);
        }

        // Finalization will revert if the auction has not yet ended.
        _finalizeReserveAuction({ auctionId: auctionId, keepInEscrow: true });
      }
      // The seller authorization has been confirmed.
      authorizeSeller = address(0);
    }

    super._transferFromEscrow(nftContract, tokenId, recipient, authorizeSeller);
  }

  /**
   * @inheritdoc NFTMarketCore
   * @dev Checks if there is an auction for this NFT before allowing the transfer to continue.
   */
  function _transferFromEscrowIfAvailable(
    address nftContract,
    uint256 tokenId,
    address recipient
  ) internal virtual override {
    if (nftContractToTokenIdToAuctionId[nftContract][tokenId] == 0) {
      // No auction was found

      super._transferFromEscrowIfAvailable(nftContract, tokenId, recipient);
    }
  }

  /**
   * @inheritdoc NFTMarketCore
   */
  function _transferToEscrow(address nftContract, uint256 tokenId) internal virtual override {
    uint256 auctionId = nftContractToTokenIdToAuctionId[nftContract][tokenId];
    if (auctionId == 0) {
      // NFT is not in auction
      super._transferToEscrow(nftContract, tokenId);
      return;
    }
    // Using storage saves gas since most of the data is not needed
    ReserveAuctionStorage storage auction = auctionIdToAuction[auctionId];
    if (auction.endTime == 0) {
      // Reserve price set, confirm the seller is a match
      if (auction.seller != msg.sender) {
        revert NFTMarketReserveAuction_Not_Matching_Seller(auction.seller);
      }
    } else {
      // Auction in progress, confirm the highest bidder is a match
      if (auction.bidder != msg.sender) {
        revert NFTMarketReserveAuction_Not_Matching_Seller(auction.bidder);
      }

      // Finalize auction but leave NFT in escrow, reverts if the auction has not ended
      _finalizeReserveAuction({ auctionId: auctionId, keepInEscrow: true });
    }
  }

  /**
   * @notice Returns the minimum amount a bidder must spend to participate in an auction.
   * Bids must be greater than or equal to this value or they will revert.
   * @param auctionId The id of the auction to check.
   * @return minimum The minimum amount for a bid to be accepted.
   */
  function getMinBidAmount(uint256 auctionId) external view returns (uint256 minimum) {
    ReserveAuctionStorage storage auction = auctionIdToAuction[auctionId];
    if (auction.endTime == 0) {
      return auction.amount;
    }
    return _getMinIncrement(auction.amount);
  }

  /**
   * @notice Returns auction details for a given auctionId.
   * @param auctionId The id of the auction to lookup.
   */
  function getReserveAuction(uint256 auctionId) external view returns (ReserveAuction memory auction) {
    ReserveAuctionStorage storage auctionStorage = auctionIdToAuction[auctionId];
    auction = ReserveAuction(
      auctionStorage.nftContract,
      auctionStorage.tokenId,
      auctionStorage.seller,
      DURATION,
      EXTENSION_DURATION,
      auctionStorage.endTime,
      auctionStorage.bidder,
      auctionStorage.amount
    );
  }

  /**
   * @notice Returns the auctionId for a given NFT, or 0 if no auction is found.
   * @dev If an auction is canceled, it will not be returned. However the auction may be over and pending finalization.
   * @param nftContract The address of the NFT contract.
   * @param tokenId The id of the NFT.
   * @return auctionId The id of the auction, or 0 if no auction is found.
   */
  function getReserveAuctionIdFor(address nftContract, uint256 tokenId) external view returns (uint256 auctionId) {
    auctionId = nftContractToTokenIdToAuctionId[nftContract][tokenId];
  }

  /**
   * @notice Returns the referrer for the current highest bid in the auction, or address(0).
   */
  function getReserveAuctionBidReferrer(uint256 auctionId) external view returns (address payable referrer) {
    ReserveAuctionStorage storage auction = auctionIdToAuction[auctionId];
    referrer = payable(
      address((uint160(auction.bidReferrerAddressSlot0) << 64) | uint160(auction.bidReferrerAddressSlot1))
    );
  }

  /**
   * @inheritdoc NFTMarketCore
   * @dev Returns the seller that has the given NFT in escrow for an auction,
   * or bubbles the call up for other considerations.
   */
  function _getSellerFor(address nftContract, uint256 tokenId)
    internal
    view
    virtual
    override
    returns (address payable seller)
  {
    seller = auctionIdToAuction[nftContractToTokenIdToAuctionId[nftContract][tokenId]].seller;
    if (seller == address(0)) {
      seller = super._getSellerFor(nftContract, tokenId);
    }
  }

  /**
   * @inheritdoc NFTMarketCore
   */
  function _isInActiveAuction(address nftContract, uint256 tokenId) internal view override returns (bool) {
    uint256 auctionId = nftContractToTokenIdToAuctionId[nftContract][tokenId];
    return auctionId != 0 && auctionIdToAuction[auctionId].endTime >= block.timestamp;
  }

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[1000] private __gap;
}
