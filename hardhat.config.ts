import { HardhatUserConfig, task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();
const {resolve} = require('path');


const config: HardhatUserConfig = {
  paths: {
    sources: resolve(__dirname, "src"),
    tests: resolve(__dirname, "test"),
    cache: resolve(__dirname, "cache"),
    artifacts: resolve(__dirname, "artifacts"),
  },
  solidity: {
    version: "0.8.13",
    settings: {
      optimizer: {
        enabled: true,
        runs: 5,
      },
    },
  },
  networks: {
    // mumbai: {
    //   url: "https://rpc-mumbai.maticvigil.com",
    //   accounts:[process.env.WALLET_PK_MUMBAI || ""]
    // },
    hardhat: {
      chainId: 31337,
      forking: {
        url: "https://polygon-mainnet.infura.io/v3/c97ed77531d74d5287facb6404446a0b",
      },
      // mining: {
      //   auto: false,
      //   interval: 2000
      // }
    },
  },
};

export default config;
