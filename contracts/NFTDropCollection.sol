// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./interfaces/internal/INFTDropCollectionInitializer.sol";
import "./interfaces/internal/INFTDropCollectionMint.sol";

import "./mixins/collections/CollectionRoyalties.sol";
import "./mixins/collections/SequentialMintCollection.sol";
import "./mixins/roles/AdminRole.sol";
import "./mixins/roles/MinterRole.sol";
import "./mixins/shared/ContractFactory.sol";

/**
 * @title A contract to batch mint a collection of NFTs.
 * @notice A 10% royalty to the creator is included which may be split with collaborators.
 * @dev A collection can have up to 4,294,967,295 (2^32-1) tokens
 * @author batu-inal & HardlyDifficult
 */
contract NFTDropCollection is
  INFTDropCollectionInitializer,
  INFTDropCollectionMint,
  IGetRoyalties,
  IGetFees,
  IRoyaltyInfo,
  ITokenCreator,
  ContractFactory,
  Initializable,
  ContextUpgradeable,
  ERC165Upgradeable,
  AccessControlUpgradeable,
  AdminRole,
  MinterRole,
  ERC721Upgradeable,
  ERC721BurnableUpgradeable,
  SequentialMintCollection,
  CollectionRoyalties
{
  using Strings for uint256;

  /****** Slot 0 (after inheritance) ******/
  /**
   * @notice The address to pay the proceeds/royalties for the collection.
   * @dev If this is set to address(0) then the proceeds go to the creator.
   */
  address payable private paymentAddress;
  /**
   * @notice Whether the collection is revealed or not.
   */
  bool public isRevealed;
  // 88 bits free space

  /****** Slot 1 ******/
  /**
   * @notice The base URI used for all NFTs in this collection.
   * @dev The `<tokenId>.json` is appended to this to obtain an NFT's `tokenURI`.
   *      e.g. The URI for `tokenId`: "1" with `baseURI`: "ipfs://foo/" is "ipfs://foo/1.json".
   * @return The base URI used by this collection.
   */
  string public baseURI;

  /****** End of storage ******/

  /**
   * @notice Emitted when the collection is revealed.
   * @param baseURI The base URI for the collection.
   * @param isRevealed Whether the collection is revealed.
   */
  event URIUpdated(string baseURI, bool isRevealed);

  modifier validBaseURI(string calldata baseURI_) {
    require(bytes(baseURI_).length > 0, "NFTDropCollection: `baseURI_` must be set");
    _;
  }

  modifier onlyWhileUnrevealed() {
    require(!isRevealed, "NFTDropCollection: Already revealed");
    _;
  }

  /**
   * @notice Initialize the template's immutable variables.
   * @param _contractFactory The factory which will be used to create collection contracts.
   */
  constructor(address _contractFactory)
    ContractFactory(_contractFactory) // solhint-disable-next-line no-empty-blocks
  {}

  /**
   * @notice Called by the contract factory on creation.
   * @param _creator The creator of this collection.
   * This account is the default admin for this collection.
   * @param _name The collection's `name`.
   * @param _symbol The collection's `symbol`.
   * @param baseURI_ The base URI for the collection.
   * @param _isRevealed Whether the collection is revealed or not.
   * @param _maxTokenId The max token id for this collection.
   * @param _approvedMinter An optional address to grant the MINTER_ROLE.
   * Set to address(0) if only admins should be granted permission to mint.
   * @param _paymentAddress The address that will receive royalties and mint payments.
   */
  function initialize(
    address payable _creator,
    string calldata _name,
    string calldata _symbol,
    string calldata baseURI_,
    bool _isRevealed,
    uint32 _maxTokenId,
    address _approvedMinter,
    address payable _paymentAddress
  ) external initializer onlyContractFactory validBaseURI(baseURI_) {
    // Initialize the NFT
    __ERC721_init(_name, _symbol);
    _initializeSequentialMintCollection(_creator, _maxTokenId);

    // Initialize royalties
    if (_paymentAddress != address(0)) {
      // If no payment address was defined, `.owner` will be returned in getTokenCreatorPaymentAddress() below.
      paymentAddress = _paymentAddress;
    }

    // Initialize URI
    baseURI = baseURI_;
    isRevealed = _isRevealed;

    // Initialize access control
    AdminRole._initializeAdminRole(_creator);
    if (_approvedMinter != address(0)) {
      MinterRole._initializeMinterRole(_approvedMinter);
    }
  }

  /**
   * @notice Allows the collection admin to burn a specific token if they currently own the NFT.
   * @param tokenId The ID of the NFT to burn.
   * @dev The function here asserts `onlyAdmin` while the super confirms ownership.
   */
  function burn(uint256 tokenId) public override onlyAdmin {
    super.burn(tokenId);
  }

  /**
   * @notice Mint `count` number of NFTs for the `to` address.
   * @dev This is only callable by an address with either the MINTER_ROLE or the DEFAULT_ADMIN_ROLE.
   * @param count The number of NFTs to mint.
   * @param to The address to mint the NFTs for.
   * @return firstTokenId The tokenId for the first NFT minted.
   * The other minted tokens are assigned sequentially, so `firstTokenId` - `firstTokenId + count - 1` were minted.
   */
  function mintCountTo(uint16 count, address to) external onlyMinterOrAdmin returns (uint256 firstTokenId) {
    require(count != 0, "NFTDropCollection: `count` must be greater than 0");

    unchecked {
      // If +1 overflows then +count would also overflow, since count > 0.
      firstTokenId = latestTokenId + 1;
    }
    latestTokenId = latestTokenId + count;
    uint256 lastTokenId = latestTokenId;
    require(lastTokenId <= maxTokenId, "NFTDropCollection: Exceeds max tokenId");

    for (uint256 i = firstTokenId; i <= lastTokenId; ) {
      _safeMint(to, i);
      unchecked {
        ++i;
      }
    }
  }

  /**
   * @notice Allows a collection admin to reveal the collection's final content.
   * @dev Once revealed, the collection's content is immutable.
   * Use `updatePreRevealContent` to update content while unrevealed.
   * @param baseURI_ The base URI of the final content for this collection.
   */
  function reveal(string calldata baseURI_) external onlyAdmin validBaseURI(baseURI_) onlyWhileUnrevealed {
    isRevealed = true;

    // Set the new base URI.
    baseURI = baseURI_;
    emit URIUpdated(baseURI_, true);
  }

  /**
   * @notice Allows a collection admin to destroy this contract only if
   * no NFTs have been minted yet or the minted NFTs have been burned.
   * @dev Once destructed, a new collection could be deployed to this address (although that's discouraged).
   */
  function selfDestruct() external onlyAdmin {
    _selfDestruct();
  }

  /**
   * @notice Allows the owner to set a max tokenID.
   * This provides a guarantee to collectors about the limit of this collection contract.
   * @dev Once this value has been set, it may be decreased but can never be increased.
   * This max may be more than the final `totalSupply` if 1 or more tokens were burned.
   * @param _maxTokenId The max tokenId to set, all NFTs must have a tokenId less than or equal to this value.
   */
  function updateMaxTokenId(uint32 _maxTokenId) external onlyAdmin {
    _updateMaxTokenId(_maxTokenId);
  }

  /**
   * @notice Allows a collection admin to update the pre-reveal content.
   * @dev Use `reveal` to reveal the final content for this collection.
   * @param baseURI_ The base URI of the pre-reveal content.
   */
  function updatePreRevealContent(string calldata baseURI_)
    external
    validBaseURI(baseURI_)
    onlyWhileUnrevealed
    onlyAdmin
  {
    baseURI = baseURI_;
    emit URIUpdated(baseURI_, false);
  }

  function _burn(uint256 tokenId) internal override(ERC721Upgradeable, SequentialMintCollection) {
    super._burn(tokenId);
  }

  /**
   * @inheritdoc CollectionRoyalties
   */
  function getTokenCreatorPaymentAddress(
    uint256 /* tokenId */
  ) public view override returns (address payable creatorPaymentAddress) {
    creatorPaymentAddress = paymentAddress;
    if (creatorPaymentAddress == address(0)) {
      creatorPaymentAddress = owner;
    }
  }

  /**
   * @notice Get the number of tokens which can still be minted.
   * @return count The max number of additional NFTs that can be minted by this collection.
   */
  function numberOfTokensAvailableToMint() external view returns (uint256 count) {
    // Mint ensures that latestTokenId is always <= maxTokenId
    unchecked {
      count = maxTokenId - latestTokenId;
    }
  }

  /**
   * @inheritdoc IERC165Upgradeable
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC165Upgradeable, AccessControlUpgradeable, ERC721Upgradeable, CollectionRoyalties)
    returns (bool interfaceSupported)
  {
    interfaceSupported = (interfaceId == type(INFTDropCollectionMint).interfaceId ||
      super.supportsInterface(interfaceId));
  }

  /**
   * @inheritdoc IERC721MetadataUpgradeable
   */
  function tokenURI(uint256 tokenId) public view override returns (string memory uri) {
    _requireMinted(tokenId);

    uri = string.concat(baseURI, tokenId.toString(), ".json");
  }
}
