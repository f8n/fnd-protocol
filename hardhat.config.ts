import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "hardhat-gas-reporter";
import "hardhat-contract-sizer";
import "@openzeppelin/hardhat-upgrades";
import { HardhatUserConfig } from "hardhat/types";
import "@primitivefi/hardhat-dodoc";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.13",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1337,
      },
    },
  },
  typechain: {
    target: "ethers-v5",
    externalArtifacts: ["node_modules/@manifoldxyz/royalty-registry-solidity/build/contracts/*.json"],
  },
  gasReporter: {
    excludeContracts: ["mocks/", "FoundationTreasury.sol", "ERC721.sol"],
  },
  dodoc: {
    runOnCompile: true,
    include: [
      "CollectionContract",
      "FETH",
      "FNDCollectionFactory",
      "FNDMiddleware",
      "FNDNFT721",
      "FNDNFTMarket",
      "FoundationTreasury",
      "PercentSplitETH",
    ],
  },
};

export default config;
