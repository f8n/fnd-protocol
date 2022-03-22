// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

/**
 * @title Interface for the main ENS reverse registrar contract.
 */
interface IReverseRegistrar {
  function setName(string memory name) external;

  function node(address addr) external pure returns (bytes32);
}
