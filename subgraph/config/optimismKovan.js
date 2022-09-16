const addresses = require("../../src/addresses/staging/69.json");
const getAddressesForSubgraph = require("./shared");

module.exports = {
  network: "optimism-kovan",
  startBlock: {
    treasury: 238000,
    nftMarket: 238000,
    nft721: 23800,
    percentSplit: 238000,
    percentSplitV1: 238000,
    percentSplitV2: 238000,
    nftCollectionFactoryV1: 238000,
    feth: 238000,
  },
  ...getAddressesForSubgraph(addresses),
};
