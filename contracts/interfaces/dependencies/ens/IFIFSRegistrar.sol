// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

/**
 * @title Interface for the main ENS FIFSRegistrar contract.
 * @notice Used in testnet only.
 */
interface IFIFSRegistrar {
  function register(bytes32 label, address owner) external;
}
