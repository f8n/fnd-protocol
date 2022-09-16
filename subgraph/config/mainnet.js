const addresses = require("../../src/addresses/prod/1.json");
const getAddressesForSubgraph = require("./shared");

module.exports = {
  network: "mainnet",
  startBlock: {
    treasury: 11648572,
    nftDropMarket: 15177208,
    nftMarket: 11648710,
    nft721: 11648721,
    percentSplitV1: 12562117,
    percentSplitV2: 13623251,
    percentSplit: 14391349,
    nftCollectionFactoryV1: 13531391,
    nftCollectionFactoryV2: 15177208,
    feth: 14335127,
  },
  ...getAddressesForSubgraph(addresses),
};
