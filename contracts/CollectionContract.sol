// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "./interfaces/ICollectionContractInitializer.sol";
import "./interfaces/ICollectionFactory.sol";
import "./interfaces/IGetRoyalties.sol";
import "./interfaces/IProxyCall.sol";
import "./interfaces/ITokenCreator.sol";
import "./interfaces/IGetFees.sol";
import "./interfaces/IRoyaltyInfo.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "./libraries/AccountMigrationLibrary.sol";
import "./libraries/ProxyCall.sol";
import "./libraries/BytesLibrary.sol";

/**
 * @title A collection of NFTs by a single creator.
 * @notice All NFTs from this contract are minted by the same creator.
 * A 10% royalty to the creator is included which may be split with collaborators on a per-NFT basis.
 */
contract CollectionContract is
  ICollectionContractInitializer,
  IGetRoyalties,
  IGetFees,
  IRoyaltyInfo,
  ITokenCreator,
  ERC721BurnableUpgradeable
{
  using AccountMigrationLibrary for address;
  using AddressUpgradeable for address;
  using BytesLibrary for bytes;
  using ProxyCall for IProxyCall;

  uint256 private constant ROYALTY_IN_BASIS_POINTS = 1000;
  uint256 private constant ROYALTY_RATIO = 10;

  /**
   * @notice The baseURI to use for the tokenURI, if undefined then `ipfs://` is used.
   */
  string private baseURI_;

  /**
   * @dev Stores hashes minted to prevent duplicates.
   */
  mapping(string => bool) private cidToMinted;

  /**
   * @notice The factory which was used to create this collection.
   * @dev This is used to read common config.
   */
  ICollectionFactory public immutable collectionFactory;

  /**
   * @notice The tokenId of the most recently created NFT.
   * @dev Minting starts at tokenId 1. Each mint will use this value + 1.
   */
  uint256 public latestTokenId;

  /**
   * @notice The max tokenId which can be minted, or 0 if there's no limit.
   * @dev This value may be set at any time, but once set it cannot be increased.
   */
  uint256 public maxTokenId;

  /**
   * @notice The owner/creator of this NFT collection.
   */
  address payable public owner;

  /**
   * @dev Stores an optional alternate address to receive creator revenue and royalty payments.
   * The target address may be a contract which could split or escrow payments.
   */
  mapping(uint256 => address payable) private tokenIdToCreatorPaymentAddress;

  /**
   * @dev Tracks how many tokens have been burned, used to calc the total supply efficiently.
   */
  uint256 private burnCounter;

  /**
   * @dev Stores a CID for each NFT.
   */
  mapping(uint256 => string) private _tokenCIDs;

  /**
   * @notice Emitted when the owner changes the base URI to be used for NFTs in this collection.
   * @param baseURI The new base URI to use.
   */
  event BaseURIUpdated(string baseURI);
  /**
   * @notice Emitted when the owner of this collection is changed through account migration.
   * @param originalAddress The address which was previously the owner.
   * @param newAddress The new address which is now the owner.
   */
  event CreatorMigrated(address indexed originalAddress, address indexed newAddress);
  /**
   * @notice Emitted when the max tokenId supported by this collection is defined.
   * @param maxTokenId The new max tokenId. All NFTs in this collection will have a tokenId less than
   * or equal to this value.
   */
  event MaxTokenIdUpdated(uint256 indexed maxTokenId);
  /**
   * @notice Emitted when a new NFT is minted.
   * @param creator The address of the collection owner at this time this NFT was minted.
   * @param tokenId The tokenId of the newly minted NFT.
   * @param indexedTokenCID The CID of the newly minted NFT, indexed to enable watching for mint events by the tokenCID.
   * @param tokenCID The actual CID of the newly minted NFT.
   */
  event Minted(address indexed creator, uint256 indexed tokenId, string indexed indexedTokenCID, string tokenCID);
  /**
   * @notice Emitted when the owner of an NFT is changed through account migration.
   * @param tokenId The tokenId of the NFT which was transferred.
   * @param originalAddress The address which was previously the owner.
   * @param newAddress The new address which is now the owner.
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
   * @notice Emitted when this collection is self destructed by the owner.
   * @param owner The collection owner at the time this collection was self destructed.
   */
  event SelfDestruct(address indexed owner);
  /**
   * @notice Emitted when the payment address for creator royalties is set.
   * @param fromPaymentAddress The original address used for royalty payments.
   * @param toPaymentAddress The new address used for royalty payments.
   * @param tokenId The NFT which had the royalty payment address updated.
   */
  event TokenCreatorPaymentAddressSet(
    address indexed fromPaymentAddress,
    address indexed toPaymentAddress,
    uint256 indexed tokenId
  );

  modifier onlyOwner() {
    require(msg.sender == owner, "CollectionContract: Caller is not owner");
    _;
  }

  modifier onlyOperator() {
    require(collectionFactory.rolesContract().isOperator(msg.sender), "CollectionContract: Caller is not an operator");
    _;
  }

  /**
   * @notice Initialize the template's immutable variables.
   * @param _collectionFactory The factory which will be used to create collection contracts.
   */
  constructor(address _collectionFactory) {
    require(_collectionFactory.isContract(), "CollectionContract: collectionFactory is not a contract");
    collectionFactory = ICollectionFactory(_collectionFactory);
  }

  /**
   * @notice Called by the factory on creation.
   * @param _creator The creator of this collection contract.
   * @param _name The name of this collection.
   * @param _symbol The symbol for this collection.
   */
  function initialize(
    address payable _creator,
    string memory _name,
    string memory _symbol
  ) external initializer {
    require(msg.sender == address(collectionFactory), "CollectionContract: Collection must be created via the factory");

    __ERC721_init_unchained(_name, _symbol);

    owner = _creator;
  }

  /**
   * @notice Allows an NFT owner or creator and Foundation to work together in order to update the creator
   * to a new account and/or transfer NFTs to that account.
   * @param ownedTokenIds The tokenIds of the NFTs owned by the original address to be migrated to the new account.
   * @param originalAddress The original account address to be migrated.
   * @param newAddress The new address for the account.
   * @param signature Message `I authorize Foundation to migrate my account to ${newAccount.address.toLowerCase()}`
   * signed by the original account.
   * @dev This will gracefully skip any NFTs that have been burned or transferred.
   */
  function adminAccountMigration(
    uint256[] calldata ownedTokenIds,
    address originalAddress,
    address payable newAddress,
    bytes calldata signature
  ) external onlyOperator {
    originalAddress.requireAuthorizedAccountMigration(newAddress, signature);

    for (uint256 i = 0; i < ownedTokenIds.length; ++i) {
      uint256 tokenId = ownedTokenIds[i];
      // Check that the token exists and still is owned by the originalAddress
      // so that frontrunning a burn or transfer will not cause the entire tx to revert
      if (_exists(tokenId) && ownerOf(tokenId) == originalAddress) {
        _transfer(originalAddress, newAddress, tokenId);
        emit NFTOwnerMigrated(tokenId, originalAddress, newAddress);
      }
    }

    if (owner == originalAddress) {
      owner = newAddress;
      emit CreatorMigrated(originalAddress, newAddress);
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
    bytes memory paymentAddressCallData,
    uint256 addressLocationInCallData,
    address originalAddress,
    address payable newAddress,
    bytes calldata signature
  ) external onlyOperator {
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
   * @param tokenId The tokenId of the NFT to burn.
   */
  function burn(uint256 tokenId) public override onlyOwner {
    super.burn(tokenId);
  }

  /**
   * @notice Allows the owner to mint an NFT defined by its metadata path.
   * @param tokenCID The CID of the NFT to mint.
   * @return tokenId The tokenId of the newly minted NFT.
   */
  function mint(string calldata tokenCID) external returns (uint256 tokenId) {
    tokenId = _mint(tokenCID);
  }

  /**
   * @notice Allows the owner to mint and sets approval for all for the provided operator.
   * @dev This can be used by creators the first time they mint an NFT to save having to issue a separate approval
   * transaction before starting an auction.
   * @param tokenCID The CID of the NFT to mint.
   * @param operator The address to set as the operator for this collection contract.
   * @return tokenId The tokenId of the newly minted NFT.
   */
  function mintAndApprove(string calldata tokenCID, address operator) external returns (uint256 tokenId) {
    tokenId = _mint(tokenCID);
    setApprovalForAll(operator, true);
  }

  /**
   * @notice Allows the owner to mint an NFT and have creator revenue/royalties sent to an alternate address.
   * @param tokenCID The CID of the NFT to mint.
   * @param tokenCreatorPaymentAddress The royalty recipient address to use for this NFT.
   * @return tokenId The tokenId of the newly minted NFT.
   */
  function mintWithCreatorPaymentAddress(string calldata tokenCID, address payable tokenCreatorPaymentAddress)
    public
    returns (uint256 tokenId)
  {
    require(tokenCreatorPaymentAddress != address(0), "CollectionContract: tokenCreatorPaymentAddress is required");
    tokenId = _mint(tokenCID);
    _setTokenCreatorPaymentAddress(tokenId, tokenCreatorPaymentAddress);
  }

  /**
   * @notice Allows the owner to mint an NFT and have creator revenue/royalties sent to an alternate address.
   * Also sets approval for all for the provided operator.
   * @dev This can be used by creators the first time they mint an NFT to save having to issue a separate approval
   * transaction before starting an auction.
   * @param tokenCID The CID of the NFT to mint.
   * @param tokenCreatorPaymentAddress The royalty recipient address to use for this NFT.
   * @param operator The address to set as the operator for this collection contract.
   * @return tokenId The tokenId of the newly minted NFT.
   */
  function mintWithCreatorPaymentAddressAndApprove(
    string calldata tokenCID,
    address payable tokenCreatorPaymentAddress,
    address operator
  ) external returns (uint256 tokenId) {
    tokenId = mintWithCreatorPaymentAddress(tokenCID, tokenCreatorPaymentAddress);
    setApprovalForAll(operator, true);
  }

  /**
   * @notice Allows the owner to mint an NFT and have creator revenue/royalties sent to an alternate address
   * which is defined by a contract call, typically a proxy contract address representing the payment terms.
   * @param tokenCID The CID of the NFT to mint.
   * @param paymentAddressFactory The contract to call which will return the address to use for payments.
   * @param paymentAddressCallData The call details to sent to the factory provided.
   * @return tokenId The tokenId of the newly minted NFT.
   */
  function mintWithCreatorPaymentFactory(
    string calldata tokenCID,
    address paymentAddressFactory,
    bytes calldata paymentAddressCallData
  ) public returns (uint256 tokenId) {
    address payable tokenCreatorPaymentAddress = collectionFactory
      .proxyCallContract()
      .proxyCallAndReturnContractAddress(paymentAddressFactory, paymentAddressCallData);
    tokenId = mintWithCreatorPaymentAddress(tokenCID, tokenCreatorPaymentAddress);
  }

  /**
   * @notice Allows the owner to mint an NFT and have creator revenue/royalties sent to an alternate address
   * which is defined by a contract call, typically a proxy contract address representing the payment terms.
   * Also sets approval for all for the provided operator.
   * @dev This can be used by creators the first time they mint an NFT to save having to issue a separate approval
   * transaction before starting an auction.
   * @param tokenCID The CID of the NFT to mint.
   * @param paymentAddressFactory The contract to call which will return the address to use for payments.
   * @param paymentAddressCallData The call details to sent to the factory provided.
   * @param operator The address to set as the operator for this collection contract.
   * @return tokenId The tokenId of the newly minted NFT.
   */
  function mintWithCreatorPaymentFactoryAndApprove(
    string calldata tokenCID,
    address paymentAddressFactory,
    bytes calldata paymentAddressCallData,
    address operator
  ) external returns (uint256 tokenId) {
    tokenId = mintWithCreatorPaymentFactory(tokenCID, paymentAddressFactory, paymentAddressCallData);
    setApprovalForAll(operator, true);
  }

  /**
   * @notice Allows the owner to assign a baseURI to use for the tokenURI instead of the default `ipfs://`.
   * @param baseURIOverride The new base URI to use for all NFTs in this collection.
   */
  function updateBaseURI(string calldata baseURIOverride) external onlyOwner {
    baseURI_ = baseURIOverride;

    emit BaseURIUpdated(baseURIOverride);
  }

  /**
   * @notice Allows the owner to set a max tokenID.
   * This provides a guarantee to collectors about the limit of this collection contract, if applicable.
   * @dev Once this value has been set, it may be decreased but can never be increased.
   * @param _maxTokenId The max tokenId to set, all NFTs must have a tokenId less than or equal to this value.
   */
  function updateMaxTokenId(uint256 _maxTokenId) external onlyOwner {
    require(_maxTokenId != 0, "CollectionContract: Max token ID may not be cleared");
    require(maxTokenId == 0 || _maxTokenId < maxTokenId, "CollectionContract: Max token ID may not increase");
    require(latestTokenId + 1 <= _maxTokenId, "CollectionContract: Max token ID must be greater than last mint");
    maxTokenId = _maxTokenId;

    emit MaxTokenIdUpdated(_maxTokenId);
  }

  /**
   * @notice Allows the collection owner to destroy this contract only if
   * no NFTs have been minted yet.
   */
  function selfDestruct() external onlyOwner {
    require(totalSupply() == 0, "CollectionContract: Any NFTs minted must be burned first");
    emit SelfDestruct(msg.sender);
    selfdestruct(payable(msg.sender));
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
    address payable originalPaymentAddress = collectionFactory.proxyCallContract().proxyCallAndReturnContractAddress(
      paymentAddressFactory,
      paymentAddressCallData
    );

    // Confirm the original address and swap with the new address
    paymentAddressCallData.replaceAtIf(addressLocationInCallData, originalAddress, newAddress);

    // Call the factory and get the newPaymentAddress
    address payable newPaymentAddress = collectionFactory.proxyCallContract().proxyCallAndReturnContractAddress(
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
          "CollectionContract: Payment address is not the expected value"
        );

        _setTokenCreatorPaymentAddress(tokenId, newPaymentAddress);
        emit PaymentAddressMigrated(tokenId, originalAddress, newAddress, originalPaymentAddress, newPaymentAddress);
      }
    }
  }

  function _burn(uint256 tokenId) internal override {
    delete cidToMinted[_tokenCIDs[tokenId]];
    delete tokenIdToCreatorPaymentAddress[tokenId];
    delete _tokenCIDs[tokenId];
    unchecked {
      // Number of burned tokens cannot overflow 256 bits.
      ++burnCounter;
    }
    super._burn(tokenId);
  }

  function _mint(string calldata tokenCID) private onlyOwner returns (uint256 tokenId) {
    require(bytes(tokenCID).length != 0, "CollectionContract: tokenCID is required");
    require(!cidToMinted[tokenCID], "CollectionContract: NFT was already minted");
    unchecked {
      // Number of tokens cannot overflow 256 bits.
      tokenId = ++latestTokenId;
      require(maxTokenId == 0 || tokenId <= maxTokenId, "CollectionContract: Max token count has already been minted");
      cidToMinted[tokenCID] = true;
      _tokenCIDs[tokenId] = tokenCID;
      _mint(msg.sender, tokenId);
      emit Minted(msg.sender, tokenId, tokenCID, tokenCID);
    }
  }

  /**
   * @dev Allow setting a different address to send payments to for both primary sale revenue
   * and secondary sales royalties.
   */
  function _setTokenCreatorPaymentAddress(uint256 tokenId, address payable tokenCreatorPaymentAddress) internal {
    emit TokenCreatorPaymentAddressSet(tokenIdToCreatorPaymentAddress[tokenId], tokenCreatorPaymentAddress, tokenId);
    tokenIdToCreatorPaymentAddress[tokenId] = tokenCreatorPaymentAddress;
  }

  /**
   * @notice Get the base URI used for all NFTs in this collection.
   * @return uri The base URI.
   */
  function baseURI() external view returns (string memory uri) {
    uri = _baseURI();
  }

  /**
   * @notice Returns an array of recipient addresses to which royalties for secondary sales should be sent.
   * The expected royalty amount is communicated with `getFeeBps`.
   * @param tokenId The tokenId of the NFT to get the royalty recipients for.
   * @return recipients An array of addresses to which royalties should be sent.
   */
  function getFeeRecipients(uint256 tokenId) external view returns (address payable[] memory recipients) {
    recipients = new address payable[](1);
    recipients[0] = getTokenCreatorPaymentAddress(tokenId);
  }

  /**
   * @notice Returns an array of royalties to be sent for secondary sales in basis points.
   * The expected recipients is communicated with `getFeeRecipients`.
   * @dev The tokenId param is ignored since all NFTs return the same value.
   * @return feesInBasisPoints The array of fees to be sent to each recipient, in basis points.
   */
  function getFeeBps(
    uint256 /* tokenId */
  ) external pure returns (uint256[] memory feesInBasisPoints) {
    feesInBasisPoints = new uint256[](1);
    feesInBasisPoints[0] = ROYALTY_IN_BASIS_POINTS;
  }

  /**
   * @notice Checks if the creator has already minted a given NFT using this collection contract.
   * @param tokenCID The CID to check for.
   * @return hasBeenMinted True if the creator has already minted an NFT with this CID.
   */
  function getHasMintedCID(string calldata tokenCID) external view returns (bool hasBeenMinted) {
    hasBeenMinted = cidToMinted[tokenCID];
  }

  /**
   * @notice Returns an array of royalties to be sent for secondary sales.
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
    recipients = new address payable[](1);
    recipients[0] = getTokenCreatorPaymentAddress(tokenId);
    feesInBasisPoints = new uint256[](1);
    feesInBasisPoints[0] = ROYALTY_IN_BASIS_POINTS;
  }

  /**
   * @notice Returns the desired payment address to be used for any transfers to the creator.
   * @dev The payment address may be assigned for each individual NFT, if not defined the collection owner is returned.
   * @param tokenId The tokenId of the NFT to get the royalties for.
   * @return tokenCreatorPaymentAddress The address to use for royalty payments for sales of this NFT.
   */
  function getTokenCreatorPaymentAddress(uint256 tokenId)
    public
    view
    returns (address payable tokenCreatorPaymentAddress)
  {
    tokenCreatorPaymentAddress = tokenIdToCreatorPaymentAddress[tokenId];
    if (tokenCreatorPaymentAddress == address(0)) {
      tokenCreatorPaymentAddress = owner;
    }
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
   * @notice Returns the creator of this NFT collection.
   * @dev The tokenId param is ignored since all NFTs return the same value.
   * @return creator The creator of this collection.
   */
  function tokenCreator(
    uint256 /* tokenId */
  ) external view returns (address payable creator) {
    creator = owner;
  }

  /**
   * @inheritdoc ERC165Upgradeable
   * @dev Checks the supported royalty interfaces.
   */
  function supportsInterface(bytes4 interfaceId) public view override returns (bool interfaceSupported) {
    if (
      interfaceId == type(IRoyaltyInfo).interfaceId ||
      interfaceId == type(ITokenCreator).interfaceId ||
      interfaceId == type(IGetRoyalties).interfaceId ||
      interfaceId == type(IGetFees).interfaceId
    ) {
      interfaceSupported = true;
    } else {
      interfaceSupported = super.supportsInterface(interfaceId);
    }
  }

  /**
   * @notice A distinct URI to the asset for a given NFT.
   * @param tokenId The tokenId of the NFT to get the URI for.
   * @return uri The URI for this NFT.
   */
  function tokenURI(uint256 tokenId) public view override returns (string memory uri) {
    require(_exists(tokenId), "CollectionContract: URI query for nonexistent token");

    uri = string(abi.encodePacked(_baseURI(), _tokenCIDs[tokenId]));
  }

  /**
   * @notice Count of NFTs tracked by this contract.
   * @dev From the ERC-721 enumerable standard.
   * @return supply The total number of NFTs still tracked by this contract.
   */
  function totalSupply() public view returns (uint256 supply) {
    unchecked {
      // Number of tokens is always >= burned tokens.
      supply = latestTokenId - burnCounter;
    }
  }

  function _baseURI() internal view override returns (string memory) {
    if (bytes(baseURI_).length != 0) {
      return baseURI_;
    }
    return "ipfs://";
  }
}
