// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "./OZ/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./NFT721Creator.sol";
import "./NFT721Market.sol";
import "./NFT721Metadata.sol";
import "./NFT721ProxyCall.sol";

/**
 * @title Allows creators to mint NFTs.
 */
abstract contract NFT721Mint is
  Initializable,
  OZERC721Upgradeable,
  NFT721ProxyCall,
  NFT721Creator,
  NFT721Market,
  NFT721Metadata
{
  /// @notice A sequence ID to use for the next minted NFT.
  uint256 private nextTokenId;

  /**
   * @notice Emitted when a new NFT is minted.
   * @param creator The address of the creator & owner at this time this NFT was minted.
   * @param tokenId The tokenId of the newly minted NFT.
   * @param indexedTokenIPFSPath The CID of the newly minted NFT, indexed to enable watching
   * for mint events by the tokenCID.
   * @param tokenIPFSPath The actual CID of the newly minted NFT.
   */
  event Minted(
    address indexed creator,
    uint256 indexed tokenId,
    string indexed indexedTokenIPFSPath,
    string tokenIPFSPath
  );

  /**
   * @dev Called once after the initial deployment to set the initial tokenId.
   */
  function _initializeNFT721Mint() internal onlyInitializing {
    // Use ID 1 for the first NFT tokenId
    nextTokenId = 1;
  }

  /**
   * @notice Allows a creator to mint an NFT.
   * @param tokenIPFSPath The IPFS path for the NFT to mint, without the leading base URI.
   * @return tokenId The tokenId of the newly minted NFT.
   */
  function mint(string calldata tokenIPFSPath) public returns (uint256 tokenId) {
    unchecked {
      // Number of tokens cannot overflow 256 bits.
      tokenId = nextTokenId++;
    }
    _mint(msg.sender, tokenId);
    _updateTokenCreator(tokenId, payable(msg.sender));
    _setTokenIPFSPath(tokenId, tokenIPFSPath);
    emit Minted(msg.sender, tokenId, tokenIPFSPath, tokenIPFSPath);
  }

  /**
   * @notice Allows a creator to mint an NFT and set approval for the Foundation marketplace.
   * @dev This can be used by creators the first time they mint an NFT to save having to issue a separate
   * approval transaction before starting an auction.
   * @param tokenIPFSPath The IPFS path for the NFT to mint, without the leading base URI.
   * @return tokenId The tokenId of the newly minted NFT.
   */
  function mintAndApproveMarket(string calldata tokenIPFSPath) external returns (uint256 tokenId) {
    tokenId = mint(tokenIPFSPath);
    setApprovalForAll(getNFTMarket(), true);
  }

  /**
   * @notice Allows a creator to mint an NFT and have creator revenue/royalties sent to an alternate address.
   * @param tokenIPFSPath The IPFS path for the NFT to mint, without the leading base URI.
   * @param tokenCreatorPaymentAddress The royalty recipient address to use for this NFT.
   * @return tokenId The tokenId of the newly minted NFT.
   */
  function mintWithCreatorPaymentAddress(string calldata tokenIPFSPath, address payable tokenCreatorPaymentAddress)
    public
    returns (uint256 tokenId)
  {
    require(tokenCreatorPaymentAddress != address(0), "NFT721Mint: tokenCreatorPaymentAddress is required");
    tokenId = mint(tokenIPFSPath);
    _setTokenCreatorPaymentAddress(tokenId, tokenCreatorPaymentAddress);
  }

  /**
   * @notice Allows a creator to mint an NFT and have creator revenue/royalties sent to an alternate address.
   * Also sets approval for the Foundation marketplace.
   * @dev This can be used by creators the first time they mint an NFT to save having to issue a separate
   * approval transaction before starting an auction.
   * @param tokenIPFSPath The IPFS path for the NFT to mint, without the leading base URI.
   * @param tokenCreatorPaymentAddress The royalty recipient address to use for this NFT.
   * @return tokenId The tokenId of the newly minted NFT.
   */
  function mintWithCreatorPaymentAddressAndApproveMarket(
    string calldata tokenIPFSPath,
    address payable tokenCreatorPaymentAddress
  ) external returns (uint256 tokenId) {
    tokenId = mintWithCreatorPaymentAddress(tokenIPFSPath, tokenCreatorPaymentAddress);
    setApprovalForAll(getNFTMarket(), true);
  }

  /**
   * @notice Allows a creator to mint an NFT and have creator revenue/royalties sent to an alternate address
   * which is defined by a contract call, typically a proxy contract address representing the payment terms.
   * @param tokenIPFSPath The IPFS path for the NFT to mint, without the leading base URI.
   * @param paymentAddressFactory The contract to call which will return the address to use for payments.
   * @param paymentAddressCallData The call details to sent to the factory provided.
   * @return tokenId The tokenId of the newly minted NFT.
   */
  function mintWithCreatorPaymentFactory(
    string calldata tokenIPFSPath,
    address paymentAddressFactory,
    bytes calldata paymentAddressCallData
  ) public returns (uint256 tokenId) {
    address payable tokenCreatorPaymentAddress = _proxyCallAndReturnContractAddress(
      paymentAddressFactory,
      paymentAddressCallData
    );
    tokenId = mintWithCreatorPaymentAddress(tokenIPFSPath, tokenCreatorPaymentAddress);
  }

  /**
   * @notice Allows a creator to mint an NFT and have creator revenue/royalties sent to an alternate address
   * which is defined by a contract call, typically a proxy contract address representing the payment terms.
   * Also sets approval for the Foundation marketplace.
   * @dev This can be used by creators the first time they mint an NFT to save having to issue a separate
   * approval transaction before starting an auction.
   * @param tokenIPFSPath The IPFS path for the NFT to mint, without the leading base URI.
   * @param paymentAddressFactory The contract to call which will return the address to use for payments.
   * @param paymentAddressCallData The call details to sent to the factory provided.
   * @return tokenId The tokenId of the newly minted NFT.
   */
  function mintWithCreatorPaymentFactoryAndApproveMarket(
    string calldata tokenIPFSPath,
    address paymentAddressFactory,
    bytes calldata paymentAddressCallData
  ) external returns (uint256 tokenId) {
    tokenId = mintWithCreatorPaymentFactory(tokenIPFSPath, paymentAddressFactory, paymentAddressCallData);
    setApprovalForAll(getNFTMarket(), true);
  }

  /**
   * @dev Explicit override to address compile errors.
   */
  function _burn(uint256 tokenId) internal virtual override(OZERC721Upgradeable, NFT721Creator, NFT721Metadata) {
    super._burn(tokenId);
  }

  /**
   * @notice Gets the tokenId of the next NFT minted.
   * @return tokenId The ID that the next NFT minted will use.
   */
  function getNextTokenId() external view returns (uint256 tokenId) {
    tokenId = nextTokenId;
  }

  /**
   * @inheritdoc ERC165
   * @dev This is required to avoid compile errors.
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(OZERC721Upgradeable, NFT721Creator, NFT721Market)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[1000] private __gap;
}
