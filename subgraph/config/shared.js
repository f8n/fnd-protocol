module.exports = function getAddressesForSubgraph(addresses) {
  return {
    treasuryAddress: addresses.treasury,
    nft721Address: addresses.nft721,
    nftMarketAddress: addresses.nftMarket,
    percentSplitV1Address: addresses.percentSplitV1,
    percentSplitV2Address: addresses.percentSplitV2,
    percentSplitAddress: addresses.percentSplit,
    collectionFactoryAddress: addresses.collectionFactory,
    fethAddress: addresses.feth,
  };
};
