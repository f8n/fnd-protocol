# FoundationTreasuryNode



> A mixin that stores a reference to the Foundation treasury contract.

The treasury collects fees and defines admin/operator roles.



## Methods

### getFoundationTreasury

```solidity
function getFoundationTreasury() external view returns (address payable treasuryAddress)
```

Gets the Foundation treasury contract.

*This call is used in the royalty registry contract.*


#### Returns

| Name | Type | Description |
|---|---|---|
| treasuryAddress | address payable | The address of the Foundation treasury contract. |




## Errors

### FoundationTreasuryNode_Address_Is_Not_A_Contract

```solidity
error FoundationTreasuryNode_Address_Is_Not_A_Contract()
```







