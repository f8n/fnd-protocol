// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

interface IERC20IncreaseAllowance {
  function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
}
