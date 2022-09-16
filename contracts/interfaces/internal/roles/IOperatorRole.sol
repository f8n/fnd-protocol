// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

/**
 * @notice Interface for OperatorRole which wraps a role from
 * OpenZeppelin's AccessControl for easy integration.
 * @author batu-inal & HardlyDifficult
 */
interface IOperatorRole {
  function isOperator(address account) external view returns (bool);
}
