const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Account:", deployer.address);
  console.log("Chain ID:", hre.network.config.chainId);

  const nftContractAddress = "0x45e9f58569d46aab2e7891d77d282eadc380e8e9";
  const randomIpfsNft = await hre.ethers.getContractAt("RandomIpfsNft", nftContractAddress);

  console.log("Requesting mint...");
  const mintTx = await randomIpfsNft.requestDoggie();
  const receipt = await mintTx.wait(10);
  console.log(receipt);
  console.log(`Minted NFT successfully.`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error during minting:", error);
    process.exit(1);
  });