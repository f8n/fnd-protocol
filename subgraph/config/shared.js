module.exports = function getAddressesForSubgraph(addresses) {
  return {
    treasuryAddress: addresses.treasury,
    nftDropMarketAddress: addresses.nftDropMarket,
    nft721Address: addresses.nft721,
    nftMarketAddress: addresses.nftMarket,
    percentSplitV1Address: addresses.percentSplitV1,
    percentSplitV2Address: addresses.percentSplitV2,
    percentSplitAddress: addresses.percentSplit,
    nftCollectionFactoryV1Address: addresses.nftCollectionFactoryV1,
    nftCollectionFactoryV2Address: addresses.nftCollectionFactoryV2,
    fethAddress: addresses.feth,
  };
};
