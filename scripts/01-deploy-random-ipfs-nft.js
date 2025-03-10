const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Chain ID:", hre.network.config.chainId);

  const FUND_AMOUNT = "10000000000000000000";
  const CALLBACK_GAS_LIMIT = "500000";
  const GAS_LANE =
    "0x9e1344a1247c8a1785d0a4681a27152bffdb43666ae5bf7d14d24a5efd44bf71";
  const TOKEN_URIS = [
    "ipfs://bafkreigclhrq7ksi72lzjmqwvfmtnifvl27cxqekmvmu3s6luk7rnxbkyy",
    "ipfs://bafkreidvsdgvt4kdtvup2ln4t2z4z2dnrjlmw2pjngnbhbpumnliqa5hiu",
    "ipfs://bafkreiadx5a7mu7jxs77zswacleogo5sq5rduzlej6vo5byzddzqvvmqiy"
  ];

  let vrfCoordinatorV2Address, subscriptionId;

  if (hre.network.config.chainId === 31337) {
    const BASE_FEE = "250000000000000000";
    const GAS_PRICE_LINK = 1e9;

    const vrfCoordinatorV2Mock = await hre.ethers.deployContract("VRFCoordinatorV2Mock", [
      BASE_FEE,
      GAS_PRICE_LINK,
    ]);
    await vrfCoordinatorV2Mock.waitForDeployment();
    console.log("VRFCoordinatorV2Mock deployed at:", vrfCoordinatorV2Mock.target);

    const txResponse = await vrfCoordinatorV2Mock.createSubscription();
    const txReceipt = await txResponse.wait(1);
    subscriptionId = txReceipt.logs[0].topics[1];
    await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, FUND_AMOUNT);
    vrfCoordinatorV2Address = vrfCoordinatorV2Mock.target;
  } else {
    vrfCoordinatorV2Address = "0x5C210eF41CD1a72de73bF76eC39637bB0d3d7BEE";
    subscriptionId =
      "69198100362267041681917894627518022775673535085807838474754956171677875434238";
  }

  const args = [
    vrfCoordinatorV2Address,
    GAS_LANE,
    subscriptionId,
    CALLBACK_GAS_LIMIT,
    TOKEN_URIS,
  ];

  const randomIpfsNft = await hre.ethers.deployContract("RandomIpfsNft", args);
  await randomIpfsNft.waitForDeployment();
  console.log("RandomIpfsNft deployed at:", randomIpfsNft.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });