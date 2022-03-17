// SPDX-License-Identifier: MIT OR Apache-2.0
// solhint-disable

pragma solidity ^0.8.0;

interface IFNDNFT721 {
  function tokenCreator(uint256 tokenId) external view returns (address payable);

  function getTokenCreatorPaymentAddress(uint256 tokenId) external view returns (address payable);
}
