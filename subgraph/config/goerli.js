const addresses = require("../../src/addresses/staging/5.json");
const getAddressesForSubgraph = require("./shared");

module.exports = {
  network: "goerli",
  startBlock: {
    treasury: 4093137,
    nftDropMarket: 7257572,
    nftMarket: 4093141,
    nft721: 4093147,
    percentSplitV1: 4901372,
    percentSplitV2: 5826847,
    percentSplit: 6421609,
    nftCollectionFactoryV1: 5746425,
    nftCollectionFactoryV2: 7257572,
    feth: 6385436,
  },
  ...getAddressesForSubgraph(addresses),
};
