require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config()
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
      hardhat: {
        chainId: 31337,
        blockConformations: 1,
        allowUnlimitedContractSize: true
      },
      base_sepolia: {
        chainId: 84532,
        url: process.env.SEPOLIA_API_URL,
        accounts: [process.env.SEPOLIA_PRIVATE_KEY]
      }
  },
  namedAccounts:{
    deployer: {
      default: 0
    }
  }
};
