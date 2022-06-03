// eslint-disable-next-line @typescript-eslint/no-var-requires
const addresses = require("../../addresses");
const getAddressesForSubgraph = require("./shared");

module.exports = {
  network: "optimism-kovan",
  startBlock: {
    treasury: 31983739,
    nftMarket: 31983739,
    percentSplitV2: 31983739,
    percentSplit: 31983739,
    collectionFactory: 31983739,
    feth: 31983739,
  },
  ...getAddressesForSubgraph(addresses.staging[69]),
};
