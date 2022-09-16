// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "../../interfaces/internal/INFTDropCollectionMint.sol";

import "../../libraries/OZERC165Checker.sol";
import "../shared/Constants.sol";
import "../shared/MarketFees.sol";

/// @param limitPerAccount The limit of tokens an account can purchase.
error NFTDropMarketFixedPriceSale_Cannot_Buy_More_Than_Limit(uint256 limitPerAccount);
error NFTDropMarketFixedPriceSale_Limit_Per_Account_Must_Be_Set();
error NFTDropMarketFixedPriceSale_Mint_Permission_Required();
error NFTDropMarketFixedPriceSale_Must_Buy_At_Least_One_Token();
error NFTDropMarketFixedPriceSale_Must_Have_Sale_In_Progress();
error NFTDropMarketFixedPriceSale_Must_Not_Be_Sold_Out();
error NFTDropMarketFixedPriceSale_Must_Not_Have_Pending_Sale();
error NFTDropMarketFixedPriceSale_Must_Support_Collection_Mint_Interface();
error NFTDropMarketFixedPriceSale_Must_Support_ERC721();
error NFTDropMarketFixedPriceSale_Only_Callable_By_Collection_Owner();
/// @param mintCost The total cost for this purchase.
error NFTDropMarketFixedPriceSale_Too_Much_Value_Provided(uint256 mintCost);
error NFTDropMarketFixedPriceSale_Mint_Count_Mismatch(uint256 targetBalance);

/**
 * @title Allows creators to list a drop collection for sale at a fixed price point.
 * @dev Listing a collection for sale in this market requires the collection to implement
 * the functions in `INFTDropCollectionMint` and to register that interface with ERC165.
 * Additionally the collection must implement access control, or more specifically:
 * `hasRole(bytes32(0), msg.sender)` must return true when called from the creator or admin's account
 * and `hasRole(keccak256("MINTER_ROLE", address(this)))` must return true for this market's address.
 * @author batu-inal & HardlyDifficult
 */
abstract contract NFTDropMarketFixedPriceSale is MarketFees {
  using AddressUpgradeable for address;
  using AddressUpgradeable for address payable;
  using ERC165Checker for address;
  using OZERC165Checker for address;

  /**
   * @notice Configuration for the terms of the sale.
   * @dev This structure is packed in order to consume just a single slot.
   */
  struct FixedPriceSaleConfig {
    /**
     * @notice The seller for the drop.
     */
    address payable seller;
    /**
     * @notice The fixed price per NFT in the collection.
     * @dev The maximum price that can be set on an NFT is ~1.2M (2^80/10^18) ETH.
     */
    uint80 price;
    /**
     * @notice The max number of NFTs an account may have while minting.
     */
    uint16 limitPerAccount;
  }

  /**
   * @notice Stores the current sale information for all drop contracts.
   */
  mapping(address => FixedPriceSaleConfig) private nftContractToFixedPriceSaleConfig;

  /**
   * @notice The `role` type used to validate drop collections have granted this market access to mint.
   * @return `keccak256("MINTER_ROLE")`
   */
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  /**
   * @notice Emitted when a collection is listed for sale.
   * @param nftContract The address of the NFT drop collection.
   * @param seller The address for the seller which listed this for sale.
   * @param price The price per NFT minted.
   * @param limitPerAccount The max number of NFTs an account may have while minting.
   */
  event CreateFixedPriceSale(
    address indexed nftContract,
    address indexed seller,
    uint256 price,
    uint256 limitPerAccount
  );

  /**
   * @notice Emitted when NFTs are minted from the drop.
   * @dev The total price paid by the buyer is `totalFees + creatorRev`.
   * @param nftContract The address of the NFT drop collection.
   * @param buyer The address of the buyer.
   * @param firstTokenId The tokenId for the first NFT minted.
   * The other minted tokens are assigned sequentially, so `firstTokenId` - `firstTokenId + count - 1` were minted.
   * @param count The number of NFTs minted.
   * @param totalFees The amount of ETH that was sent to Foundation & referrals for this sale.
   * @param creatorRev The amount of ETH that was sent to the creator for this sale.
   */
  event MintFromFixedPriceDrop(
    address indexed nftContract,
    address indexed buyer,
    uint256 indexed firstTokenId,
    uint256 count,
    uint256 totalFees,
    uint256 creatorRev
  );

  /**
   * @notice Create a fixed price sale drop.
   * @param nftContract The address of the NFT drop collection.
   * @param price The price per NFT minted.
   * Set price to 0 for a first come first serve airdrop-like drop.
   * @param limitPerAccount The max number of NFTs an account may have while minting.
   * @dev Notes:
   *   a) The sale is final and can not be updated or canceled.
   *   b) The sale is immediately kicked off.
   *   c) Any collection that abides by `INFTDropCollectionMint` and `IAccessControl` is supported.
   */
  /* solhint-disable-next-line code-complexity */
  function createFixedPriceSale(
    address nftContract,
    uint80 price,
    uint16 limitPerAccount
  ) external {
    // Confirm the drop collection is supported
    if (!nftContract.supportsInterface(type(INFTDropCollectionMint).interfaceId)) {
      revert NFTDropMarketFixedPriceSale_Must_Support_Collection_Mint_Interface();
    }
    // The check above already confirmed general 165 support
    if (!nftContract.supportsERC165InterfaceUnchecked(type(IERC721).interfaceId)) {
      revert NFTDropMarketFixedPriceSale_Must_Support_ERC721();
    }
    if (INFTDropCollectionMint(nftContract).numberOfTokensAvailableToMint() == 0) {
      revert NFTDropMarketFixedPriceSale_Must_Not_Be_Sold_Out();
    }

    // Use the AccessControl interface to confirm the msg.sender has permissions to list.
    if (!IAccessControl(nftContract).hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
      revert NFTDropMarketFixedPriceSale_Only_Callable_By_Collection_Owner();
    }
    // And that this contract has permission to mint.
    if (!IAccessControl(nftContract).hasRole(MINTER_ROLE, address(this))) {
      revert NFTDropMarketFixedPriceSale_Mint_Permission_Required();
    }

    // Validate input params.
    if (limitPerAccount == 0) {
      revert NFTDropMarketFixedPriceSale_Limit_Per_Account_Must_Be_Set();
    }
    // Any price is supported, including 0.

    // Confirm this collection has not already been listed.
    FixedPriceSaleConfig storage saleConfig = nftContractToFixedPriceSaleConfig[nftContract];
    if (saleConfig.seller != payable(0)) {
      revert NFTDropMarketFixedPriceSale_Must_Not_Have_Pending_Sale();
    }

    // Save the sale details.
    saleConfig.seller = payable(msg.sender);
    saleConfig.price = price;
    saleConfig.limitPerAccount = limitPerAccount;
    emit CreateFixedPriceSale(nftContract, msg.sender, price, limitPerAccount);
  }

  /**
   * @notice Used to mint `count` number of NFTs from the collection.
   * @param nftContract The address of the NFT drop collection.
   * @param count The number of NFTs to mint.
   * @param buyReferrer The address which referred this purchase, or address(0) if n/a.
   * @return firstTokenId The tokenId for the first NFT minted.
   * The other minted tokens are assigned sequentially, so `firstTokenId` - `firstTokenId + count - 1` were minted.
   * @dev This call may revert if the collection has sold out, has an insufficient number of tokens available,
   * or if the market's minter permissions were removed.
   * If insufficient msg.value is included, the msg.sender's available FETH token balance will be used.
   */
  function mintFromFixedPriceSale(
    address nftContract,
    uint16 count,
    address payable buyReferrer
  ) external payable returns (uint256 firstTokenId) {
    // Validate input params.
    if (count == 0) {
      revert NFTDropMarketFixedPriceSale_Must_Buy_At_Least_One_Token();
    }

    FixedPriceSaleConfig memory saleConfig = nftContractToFixedPriceSaleConfig[nftContract];

    // Confirm that the buyer will not exceed the limit specified after minting.
    uint256 targetBalance = IERC721(nftContract).balanceOf(msg.sender) + count;
    if (targetBalance > saleConfig.limitPerAccount) {
      if (saleConfig.limitPerAccount == 0) {
        // Provide a more targeted error if the collection has not been listed.
        revert NFTDropMarketFixedPriceSale_Must_Have_Sale_In_Progress();
      }
      revert NFTDropMarketFixedPriceSale_Cannot_Buy_More_Than_Limit(saleConfig.limitPerAccount);
    }

    // Calculate the total cost, considering the `count` requested.
    uint256 mintCost;
    unchecked {
      // Can not overflow as 2^80 * 2^16 == 2^96 max which fits in 256 bits.
      mintCost = uint256(saleConfig.price) * count;
    }

    // The sale price is immutable so the buyer is aware of how much they will be paying when their tx is broadcasted.
    if (msg.value > mintCost) {
      // Since price is known ahead of time, if too much ETH is sent then something went wrong.
      revert NFTDropMarketFixedPriceSale_Too_Much_Value_Provided(mintCost);
    }
    // Withdraw from the user's available FETH balance if insufficient msg.value was included.
    _tryUseFETHBalance(mintCost, false);

    // Mint the NFTs.
    firstTokenId = INFTDropCollectionMint(nftContract).mintCountTo(count, msg.sender);

    if (IERC721(nftContract).balanceOf(msg.sender) != targetBalance) {
      revert NFTDropMarketFixedPriceSale_Mint_Count_Mismatch(targetBalance);
    }

    // Distribute revenue from this sale.
    (uint256 totalFees, uint256 creatorRev, ) = _distributeFunds(
      nftContract,
      firstTokenId,
      saleConfig.seller,
      mintCost,
      buyReferrer
    );

    emit MintFromFixedPriceDrop(nftContract, msg.sender, firstTokenId, count, totalFees, creatorRev);
  }

  /**
   * @notice Returns the max number of NFTs a given account may mint.
   * @param nftContract The address of the NFT drop collection.
   * @param user The address of the user which will be minting.
   * @return numberThatCanBeMinted How many NFTs the user can mint.
   */
  function getAvailableCountFromFixedPriceSale(address nftContract, address user)
    external
    view
    returns (uint256 numberThatCanBeMinted)
  {
    (, , uint256 limitPerAccount, uint256 numberOfTokensAvailableToMint, bool marketCanMint) = getFixedPriceSale(
      nftContract
    );
    if (!marketCanMint) {
      // No one can mint in the current state.
      return 0;
    }
    uint256 currentBalance = IERC721(nftContract).balanceOf(user);
    if (currentBalance >= limitPerAccount) {
      // User has exhausted their limit.
      return 0;
    }

    unchecked {
      numberThatCanBeMinted = limitPerAccount - currentBalance;
    }
    if (numberThatCanBeMinted > numberOfTokensAvailableToMint) {
      // User has more tokens available than the collection has available.
      numberThatCanBeMinted = numberOfTokensAvailableToMint;
    }
  }

  /**
   * @notice Returns details for a drop collection's fixed price sale.
   * @param nftContract The address of the NFT drop collection.
   * @return seller The address of the seller which listed this drop for sale.
   * This value will be address(0) if the collection is not listed or has sold out.
   * @return price The price per NFT minted.
   * @return limitPerAccount The max number of NFTs an account may have while minting.
   * @return numberOfTokensAvailableToMint The total number of NFTs that may still be minted.
   * @return marketCanMint True if this contract has permissions to mint from the given collection.
   */
  function getFixedPriceSale(address nftContract)
    public
    view
    returns (
      address payable seller,
      uint256 price,
      uint256 limitPerAccount,
      uint256 numberOfTokensAvailableToMint,
      bool marketCanMint
    )
  {
    try INFTDropCollectionMint(nftContract).numberOfTokensAvailableToMint() returns (uint256 count) {
      if (count != 0) {
        try IAccessControl(nftContract).hasRole(MINTER_ROLE, address(this)) returns (bool hasRole) {
          marketCanMint = hasRole;
        } catch {
          // The contract is not supported - return default values.
          return (payable(0), 0, 0, 0, false);
        }

        FixedPriceSaleConfig memory saleConfig = nftContractToFixedPriceSaleConfig[nftContract];
        seller = saleConfig.seller;
        price = saleConfig.price;
        limitPerAccount = saleConfig.limitPerAccount;
        numberOfTokensAvailableToMint = count;
      }
      // Else minted completed -- return default values.
    } catch // solhint-disable-next-line no-empty-blocks
    {
      // Contract not supported or self destructed - return default values
    }
  }

  /**
   * @inheritdoc MarketSharedCore
   * @dev Returns the seller for a collection if listed and not already sold out.
   */
  function _getSellerOf(
    address nftContract,
    uint256 /* tokenId */
  ) internal view virtual override returns (address payable seller) {
    (seller, , , , ) = getFixedPriceSale(nftContract);
  }

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[1_000] private __gap;
}
