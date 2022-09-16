// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

/**
 * @author batu-inal & HardlyDifficult
 */
interface INFTDropCollectionInitializer {
  function initialize(
    address payable _creator,
    string calldata _name,
    string calldata _symbol,
    string calldata _baseURI,
    bool isRevealed,
    uint32 _maxTokenId,
    address _approvedMinter,
    address payable _paymentAddress
  ) external;
}
