// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

interface ICollectionContractInitializer {
  function initialize(
    address payable _creator,
    string memory _name,
    string memory _symbol
  ) external;
}
