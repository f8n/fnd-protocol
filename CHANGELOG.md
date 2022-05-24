# Changelog

## 2.2.3.1

- NPM package: add `subgraphEndpoints.js` with the URLs to use when querying subgraph.

## 2.2.3

- Remove Private Sales
- Try/catch `tokenCreator` so that other royalty APIs are checked for contracts with a fallback function.
- Ignore `owner` when address(0)

## 2.2.2

- Middleware: Fix `probeNFT` for fallback function in the royalty recipient.
- Upgrade to [solc 0.8.14](https://github.com/ethereum/solidity/releases/tag/v0.8.14)

## 2.2.1

### Market

- Try try catch so that contracts with a fallback function or unsupported return types do not cause the NFT to get stuck in escrow.

## 2.2.0

### Market

- Bid Referrals: adds `placeBidV2` with referral incentives and `getReserveAuctionBidReferrer`.
- Offer Referrals: adds `makeOfferV2` with referral incentives and `getOfferReferrer`.
- Auction gas savings: don't store duration/extension.

## 2.1.1

### Middleware

- Catch reverts in `getFees` and return `keccak256("Failed to getFees")`.

## 2.1.0

### General

- Upgrade to [solc 0.8.13](https://github.com/ethereum/solidity/releases/tag/v0.8.13)

### Market

- Buy referrals: adds `buyV2` with referral incentives.
- Royalties: ignore `royaltyInfo` from the NFT contract when the amount is 0 (does not impact the royalty override)
- On placeBidOf, leverage FETH from an outstanding offer.
- Remove withdraw from escrow (leaning on fallback to FETH instead).
- Revert when setting the same buy or reserve price.
- Don't check royalty APIs for non-address(0) recipient (still checks length > 0).
- Use OZ ECDSA for private sale signature verification.
- Gas optimizations & style improvements.

### Middleware

- Switch `probeNFT` to return bytes32 instead of throwing errors.

## 2.0.3

### Middleware

- `probeNFT`

## 2.0.1

### Percent Split Factory

- Block proxy to `increaseAllowance`
- Optimize storage to save gas
