// eslint-disable-next-line @typescript-eslint/no-var-requires
const addresses = require("../../addresses");
const getAddressesForSubgraph = require("./shared");

module.exports = {
  network: "optimism-kovan",
  startBlock: {
    treasury: 238000,
    nftMarket: 238000,
    percentSplitV2: 238000,
    percentSplit: 238000,
    collectionFactory: 238000,
    feth: 238000,
  },
  ...getAddressesForSubgraph(addresses.staging[69]),
};
