/**
 * Mainnet: 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
 * Goerli: 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6
 */

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

interface IWETH9 {
  function deposit() external payable;

  function transfer(address to, uint256 value) external returns (bool);
}
