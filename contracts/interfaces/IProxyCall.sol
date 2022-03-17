// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

interface IProxyCall {
  function proxyCallAndReturnAddress(address externalContract, bytes memory callData)
    external
    returns (address payable result);
}
