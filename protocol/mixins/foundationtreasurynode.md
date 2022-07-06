# FoundationTreasuryNode

> A mixin that stores a reference to the Foundation treasury contract.

The treasury collects fees and defines admin/operator roles.

## Methods

### getFoundationTreasury

```solidity
function getFoundationTreasury() external view returns (address payable treasuryAddress)
```

Gets the Foundation treasury contract.

_This call is used in the royalty registry contract._

#### Returns

| Name            | Type              | Description                                      |
| --------------- | ----------------- | ------------------------------------------------ |
| treasuryAddress | `address payable` | The address of the Foundation treasury contract. |

## Events

### Initialized

```solidity
event Initialized(uint8 version)
```

#### Parameters

| Name    | Type    |
| ------- | ------- |
| version | `uint8` |

## Errors

### FoundationTreasuryNode\_Address\_Is\_Not\_A\_Contract

```solidity
error FoundationTreasuryNode_Address_Is_Not_A_Contract()
```
