// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

/**
 * @title Interface for the main ENS resolver contract.
 */
interface IPublicResolver {
  function setAddr(bytes32 node, address a) external;

  function name(bytes32 node) external view returns (string memory);
}
