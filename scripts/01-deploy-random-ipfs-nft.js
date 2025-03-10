const hre = require("hardhat");
async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const chainId = network.config.chainId
    console.log("Deploying contracts to chainid:", chainId);
    let vrfCoordinatorV2Address, subscriptionId
    const FUND_AMOUNT = "10000000000000000000"
    const callBackGasLimit = "500000"
    const gasLane = "0x9e1344a1247c8a1785d0a4681a27152bffdb43666ae5bf7d14d24a5efd44bf71"
    const tokenUris = [
        "ipfs://bafkreigclhrq7ksi72lzjmqwvfmtnifvl27cxqekmvmu3s6luk7rnxbkyy",
        "ipfs://bafkreidvsdgvt4kdtvup2ln4t2z4z2dnrjlmw2pjngnbhbpumnliqa5hiu",
        "ipfs://bafkreiadx5a7mu7jxs77zswacleogo5sq5rduzlej6vo5byzddzqvvmqiy"
    ]
    // if we are working with a testnet or a mainnet
    // those addresses will exist
    // otherwise ... they don't

    if(chainId == 31337) {
        const BASE_FEE = "250000000000000000"
        const GAS_PRICE_LINK = 1e9;     
        //const meta_0 = await hre.network.provider.send("hardhat_metadata");
        //console.log(meta_0);
        const vrfCoordinatorV2Mock = await ethers.deployContract("VRFCoordinatorV2Mock", [BASE_FEE, GAS_PRICE_LINK])
        console.log("VRFCoordinatorMock is Deployed at: ", vrfCoordinatorV2Mock.target)
        const transactionResponse = await vrfCoordinatorV2Mock.createSubscription();
        const transactionReceipt = await transactionResponse.wait(1);
        //console.log(transactionReceipt);
        subscriptionId = transactionReceipt.logs[0].topics[1];
        //console.log(subscriptionId)
        await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, FUND_AMOUNT) 
        const result = await vrfCoordinatorV2Mock.getSubscription(subscriptionId)
        //console.log(result)
        vrfCoordinatorV2Address=vrfCoordinatorV2Mock.target
    } else {
        // use the real ones 
        vrfCoordinatorV2Address = "0x5C210eF41CD1a72de73bF76eC39637bB0d3d7BEE"
        subscriptionId = "69198100362267041681917894627518022775673535085807838474754956171677875434238"
    }

    args = [
        vrfCoordinatorV2Address,
        gasLane,
        subscriptionId,
        callBackGasLimit,
        tokenUris
    ]

    const randomIpfsNft = await ethers.deployContract("RandomIpfsNft", args)
    console.log("NFT Contract is Deployed at: ", randomIpfsNft.target)

}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });