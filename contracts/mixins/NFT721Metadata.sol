// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "./NFT721Core.sol";
import "./NFT721Creator.sol";

/**
 * @title A mixin to extend the OpenZeppelin metadata implementation.
 */
abstract contract NFT721Metadata is NFT721Creator {
  using Strings for uint256;

  /// @notice Stores hashes minted by a creator to prevent duplicates.
  mapping(address => mapping(string => bool)) private creatorToIPFSHashToMinted;

  /**
   * @notice Emitted when the base URI used by NFTs created by this contract is updated.
   * @param baseURI The new base URI to use for all NFTs created by this contract.
   */
  event BaseURIUpdated(string baseURI);

  /**
   * @notice Returns the IPFS path to the metadata JSON file for a given NFT.
   * @param tokenId The NFT to get the CID path for.
   * @return path The IPFS path to the metadata JSON file, without the base URI prefix.
   */
  function getTokenIPFSPath(uint256 tokenId) external view returns (string memory path) {
    path = _tokenURIs[tokenId];
  }

  /**
   * @notice Checks if the creator has already minted a given NFT.
   * @param creator The creator which may have minted this NFT already.
   * @param tokenIPFSPath The IPFS path to the metadata JSON file, without the base URI prefix.
   * @return hasMinted True if the creator has already minted this NFT.
   */
  function getHasCreatorMintedIPFSHash(address creator, string calldata tokenIPFSPath)
    external
    view
    returns (bool hasMinted)
  {
    hasMinted = creatorToIPFSHashToMinted[creator][tokenIPFSPath];
  }

  /**
   * @dev When a token is burned, remove record of it allowing that creator to re-mint the same NFT again in the future.
   */
  function _burn(uint256 tokenId) internal virtual override {
    delete creatorToIPFSHashToMinted[msg.sender][_tokenURIs[tokenId]];
    super._burn(tokenId);
  }

  /**
   * @dev The IPFS path should be the CID + file.extension, e.g.
   * `QmfPsfGwLhiJrU8t9HpG4wuyjgPo9bk8go4aQqSu9Qg4h7/metadata.json`
   */
  function _setTokenIPFSPath(uint256 tokenId, string calldata _tokenIPFSPath) internal {
    // 46 is the minimum length for an IPFS content hash, it may be longer if paths are used
    require(bytes(_tokenIPFSPath).length >= 46, "NFT721Metadata: Invalid IPFS path");
    require(!creatorToIPFSHashToMinted[msg.sender][_tokenIPFSPath], "NFT721Metadata: NFT was already minted");

    creatorToIPFSHashToMinted[msg.sender][_tokenIPFSPath] = true;
    _setTokenURI(tokenId, _tokenIPFSPath);
  }

  function _updateBaseURI(string calldata _baseURI) internal {
    _setBaseURI(_baseURI);

    emit BaseURIUpdated(_baseURI);
  }

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   * @dev 1 slot was used with the addition of `creatorToIPFSHashToMinted`.
   */
  uint256[999] private __gap;
}
