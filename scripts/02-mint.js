const hre = require("hardhat");
async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Interacting contracts with the account:", deployer.address);

    const chainId = network.config.chainId
    console.log("Interacting contracts to chainid:", chainId);
    const randomIpfsNft = await ethers.getContractAt("RandomIpfsNft","0x79245700fccb6c3c41732ff44279638536fc88e9")    
    console.log(randomIpfsNft)
    const randomIpfsNftMintTx = await randomIpfsNft.requestDoggie()
    const randomIpfsNftMintTxReceipt = await randomIpfsNftMintTx.wait(1)
    console.log(randomIpfsNftMintTxReceipt)

}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });