// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

interface IERC20Approve {
  function approve(address spender, uint256 amount) external returns (bool);
}
