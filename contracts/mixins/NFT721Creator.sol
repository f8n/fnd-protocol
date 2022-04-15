// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "./OZ/ERC721Upgradeable.sol";
import "../libraries/BytesLibrary.sol";
import "./NFT721ProxyCall.sol";
import "../interfaces/ITokenCreator.sol";
import "../libraries/AccountMigrationLibrary.sol";
import "./FoundationTreasuryNode.sol";

/**
 * @title Allows each token to be associated with a creator.
 * @notice Also manages the payment address for each NFT, allowing royalties to be split with collaborators.
 */
abstract contract NFT721Creator is FoundationTreasuryNode, OZERC721Upgradeable, ITokenCreator, NFT721ProxyCall {
  using AccountMigrationLibrary for address;
  using BytesLibrary for bytes;

  /**
   * @notice Stores the creator address for each NFT.
   */
  mapping(uint256 => address payable) private tokenIdToCreator;

  /**
   * @notice Stores an optional alternate address to receive creator revenue and royalty payments.
   * The target address may be a contract which could split or escrow payments.
   * @dev This is address(0) when not applicable and royalties should be sent to the creator instead.
   */
  mapping(uint256 => address payable) private tokenIdToCreatorPaymentAddress;

  /**
   * @notice Emitted when the creator for an NFT is set.
   * @param fromCreator The original creator address for this NFT.
   * @param toCreator The new creator address for this NFT.
   * @param tokenId The token ID for the NFT which was updated.
   */
  event TokenCreatorUpdated(address indexed fromCreator, address indexed toCreator, uint256 indexed tokenId);
  /**
   * @notice Emitted when the creator payment address for an NFT is set.
   * @param fromPaymentAddress The original creator payment address for this NFT.
   * @param toPaymentAddress The new creator payment address for this NFT.
   * @param tokenId The token ID for the NFT which was updated.
   */
  event TokenCreatorPaymentAddressSet(
    address indexed fromPaymentAddress,
    address indexed toPaymentAddress,
    uint256 indexed tokenId
  );
  /**
   * @notice Emitted when the creator for an NFT is changed through account migration.
   * @param tokenId The tokenId of the NFT which had the creator changed.
   * @param originalAddress The original creator address for this NFT.
   * @param newAddress The new creator address for this NFT.
   */
  event NFTCreatorMigrated(uint256 indexed tokenId, address indexed originalAddress, address indexed newAddress);
  /**
   * @notice Emitted when the owner of an NFT is changed through account migration.
   * @param tokenId The tokenId of the NFT which had the owner changed.
   * @param originalAddress The original owner address for this NFT.
   * @param newAddress The new owner address for this NFT.
   */
  event NFTOwnerMigrated(uint256 indexed tokenId, address indexed originalAddress, address indexed newAddress);
  /**
   * @notice Emitted when the payment address for an NFT is changed through account migration.
   * @param tokenId The tokenId of the NFT which had the payment address changed.
   * @param originalAddress The original recipient address for royalties that is being migrated.
   * @param newAddress The new recipient address for royalties.
   * @param originalPaymentAddress The original payment address for royalty payments.
   * @param newPaymentAddress The new payment address used to split royalty payments.
   */
  event PaymentAddressMigrated(
    uint256 indexed tokenId,
    address indexed originalAddress,
    address indexed newAddress,
    address originalPaymentAddress,
    address newPaymentAddress
  );

  /**
   * @notice Allows an NFT owner or creator and Foundation to work together in order to update the creator
   * to a new account and/or transfer NFTs to that account.
   * @dev This will gracefully skip any NFTs that have been burned or transferred.
   * @param createdTokenIds The tokenIds of the NFTs which were created by the original address.
   * @param ownedTokenIds The tokenIds of the NFTs owned by the original address to be migrated to the new account.
   * @param originalAddress The original account address to be migrated.
   * @param newAddress The new address for the account.
   * @param signature Message `I authorize Foundation to migrate my account to ${newAccount.address.toLowerCase()}`
   * signed by the original account.
   */
  function adminAccountMigration(
    uint256[] calldata createdTokenIds,
    uint256[] calldata ownedTokenIds,
    address originalAddress,
    address payable newAddress,
    bytes calldata signature
  ) external onlyFoundationOperator {
    originalAddress.requireAuthorizedAccountMigration(newAddress, signature);
    unchecked {
      // The array length cannot overflow 256 bits.
      for (uint256 i = 0; i < ownedTokenIds.length; ++i) {
        uint256 tokenId = ownedTokenIds[i];
        // Check that the token exists and still owned by the originalAddress
        // so that frontrunning a burn or transfer will not cause the entire tx to revert
        if (_exists(tokenId) && ownerOf(tokenId) == originalAddress) {
          _transfer(originalAddress, newAddress, tokenId);
          emit NFTOwnerMigrated(tokenId, originalAddress, newAddress);
        }
      }

      for (uint256 i = 0; i < createdTokenIds.length; ++i) {
        uint256 tokenId = createdTokenIds[i];
        // The creator would be 0 if the token was burned before this call
        if (tokenIdToCreator[tokenId] != address(0)) {
          require(
            tokenIdToCreator[tokenId] == originalAddress,
            "NFT721Creator: Token was not created by the given address"
          );
          _updateTokenCreator(tokenId, newAddress);
          emit NFTCreatorMigrated(tokenId, originalAddress, newAddress);
        }
      }
    }
  }

  /**
   * @notice Allows a split recipient and Foundation to work together in order to update the payment address
   * to a new account.
   * @param paymentAddressTokenIds The token IDs for the NFTs to have their payment address migrated.
   * @param paymentAddressFactory The contract which was used to generate the payment address being migrated.
   * @param paymentAddressCallData The original call data used to generate the payment address being migrated.
   * @param addressLocationInCallData The position where the account to migrate begins in the call data.
   * @param originalAddress The original account address to be migrated.
   * @param newAddress The new address for the account.
   * @param signature Message `I authorize Foundation to migrate my account to ${newAccount.address.toLowerCase()}`
   * signed by the original account.
   */
  function adminAccountMigrationForPaymentAddresses(
    uint256[] calldata paymentAddressTokenIds,
    address paymentAddressFactory,
    bytes calldata paymentAddressCallData,
    uint256 addressLocationInCallData,
    address originalAddress,
    address payable newAddress,
    bytes calldata signature
  ) external onlyFoundationOperator {
    originalAddress.requireAuthorizedAccountMigration(newAddress, signature);
    _adminAccountRecoveryForPaymentAddresses(
      paymentAddressTokenIds,
      paymentAddressFactory,
      paymentAddressCallData,
      addressLocationInCallData,
      originalAddress,
      newAddress
    );
  }

  /**
   * @notice Allows the creator to burn if they currently own the NFT.
   * @param tokenId The tokenId of the NFT to be burned.
   */
  function burn(uint256 tokenId) external {
    require(tokenIdToCreator[tokenId] == msg.sender, "NFT721Creator: Caller is not creator");
    require(_isApprovedOrOwner(msg.sender, tokenId), "NFT721Creator: Caller is not owner nor approved");
    _burn(tokenId);
  }

  /**
   * @dev Split into a second function to avoid stack too deep errors
   */
  function _adminAccountRecoveryForPaymentAddresses(
    uint256[] calldata paymentAddressTokenIds,
    address paymentAddressFactory,
    bytes memory paymentAddressCallData,
    uint256 addressLocationInCallData,
    address originalAddress,
    address payable newAddress
  ) private {
    // Call the factory and get the originalPaymentAddress
    address payable originalPaymentAddress = _proxyCallAndReturnContractAddress(
      paymentAddressFactory,
      paymentAddressCallData
    );

    // Confirm the original address and swap with the new address
    paymentAddressCallData.replaceAtIf(addressLocationInCallData, originalAddress, newAddress);

    // Call the factory and get the newPaymentAddress
    address payable newPaymentAddress = _proxyCallAndReturnContractAddress(
      paymentAddressFactory,
      paymentAddressCallData
    );

    // For each token, confirm the expected payment address and then update to the new one
    unchecked {
      // The array length cannot overflow 256 bits.
      for (uint256 i = 0; i < paymentAddressTokenIds.length; ++i) {
        uint256 tokenId = paymentAddressTokenIds[i];
        require(
          tokenIdToCreatorPaymentAddress[tokenId] == originalPaymentAddress,
          "NFT721Creator: Payment address is not the expected value"
        );

        _setTokenCreatorPaymentAddress(tokenId, newPaymentAddress);
        emit PaymentAddressMigrated(tokenId, originalAddress, newAddress, originalPaymentAddress, newPaymentAddress);
      }
    }
  }

  /**
   * @dev Remove the creator and payment address records when burned.
   */
  function _burn(uint256 tokenId) internal virtual override {
    delete tokenIdToCreator[tokenId];
    delete tokenIdToCreatorPaymentAddress[tokenId];

    // Delete the NFT details.
    super._burn(tokenId);
  }

  /**
   * @dev Allow setting a different address to send payments to for both primary sale revenue
   * and secondary sales royalties.
   */
  function _setTokenCreatorPaymentAddress(uint256 tokenId, address payable tokenCreatorPaymentAddress) internal {
    emit TokenCreatorPaymentAddressSet(tokenIdToCreatorPaymentAddress[tokenId], tokenCreatorPaymentAddress, tokenId);
    tokenIdToCreatorPaymentAddress[tokenId] = tokenCreatorPaymentAddress;
  }

  function _updateTokenCreator(uint256 tokenId, address payable creator) internal {
    emit TokenCreatorUpdated(tokenIdToCreator[tokenId], creator, tokenId);

    tokenIdToCreator[tokenId] = creator;
  }

  /**
   * @notice Returns the payment address for a given tokenId.
   * @dev If an alternate address was not defined, the creator is returned instead.
   * @param tokenId The tokenId of the NFT to get the payment address for.
   * @return tokenCreatorPaymentAddress The address to which royalties should be sent for this NFT.
   */
  function getTokenCreatorPaymentAddress(uint256 tokenId)
    public
    view
    returns (address payable tokenCreatorPaymentAddress)
  {
    tokenCreatorPaymentAddress = tokenIdToCreatorPaymentAddress[tokenId];
    if (tokenCreatorPaymentAddress == address(0)) {
      tokenCreatorPaymentAddress = tokenIdToCreator[tokenId];
    }
  }

  /**
   * @inheritdoc ERC165
   * @dev Checks the ITokenCreator interface.
   */
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    if (interfaceId == type(ITokenCreator).interfaceId) {
      return true;
    }
    return super.supportsInterface(interfaceId);
  }

  /**
   * @notice Returns the creator's address for a given tokenId.
   * @param tokenId The tokenId of the NFT to get the creator for.
   * @return creator The creator's address for the given tokenId.
   */
  function tokenCreator(uint256 tokenId) external view override returns (address payable creator) {
    creator = tokenIdToCreator[tokenId];
  }

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   * @dev 1 slot was using with the addition of `tokenIdToCreatorPaymentAddress`.
   */
  uint256[999] private __gap;
}
