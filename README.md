# Sample NFT Project with ChainLink VRF

This project demonstrates how to create a set of NFTs, enable the randomness of minting, and list them in OpenSea.

## Understand NFT

Please read: [ERC-721: Non-Fungible Token Standard](https://eips.ethereum.org/EIPS/eip-721)

## Store NFT Image at ...

### ...  a server, just like what we always do

Go to [OpenSea](https://opensea.io/), an NFT marketplace, pick a random NFT collection, pick a random NFT.

Let's say I pick [Fidenza #956](https://opensea.io/assets/ethereum/0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270/78000956).

From its details, I found its contract address and token id.

```
Contract Address 0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270
Token ID  78000956
```

As they contains URLs, we can just go to the contract and token URI
- [contract address](https://etherscan.io/address/0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270#readContract)
- [NFT URI](https://token.artblocks.io/78000956)

We found that the `primary_asset_url`
```
{
    "primary_asset_url": "https://media-proxy.artblocks.io/0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270/78000956.png"
}
```

And it points us to an [Amazon S3 bucket](https://artblocks-mainnet.s3.amazonaws.com/78000956.png).

### ... a decentralized server, so it won't get down easily

For example, I pick [Pudgy Penguin #7183](https://opensea.io/assets/ethereum/0xbd3531da5cf5857e7cfaa92426877b022e612cf8/7183) and go to tis token URI. I get a link starting with `ipfs.io/ipfs/`, which following contents
```
{
  "attributes": [
    {
      "trait_type": "Background",
      "value": "Blue"
    },
    {
      "trait_type": "Skin",
      "value": "Light Gray"
    },
    {
      "trait_type": "Body",
      "value": "Apron"
    },
    {
      "trait_type": "Face",
      "value": "Cross Eyed"
    },
    {
      "trait_type": "Head",
      "value": "Party Hat"
    }
  ],
  "description": "A collection 8888 Cute Chubby Pudgy Penquins sliding around on the freezing ETH blockchain.",
  "image": "ipfs://QmNf1UsmdGaMbpatQ6toXSkzDpizaGmC9zfunCyoz1enD5/penguin/7183.png",
  "name": "Pudgy Penguin #7183"
}
```

It contains all attributes to the Penguin, but I want to access its image. Simply copy-pasting the IPFS to web browser won't work. Unlike we we experienced with AWS S3.
```
{
    "image": "ipfs://QmNf1UsmdGaMbpatQ6toXSkzDpizaGmC9zfunCyoz1enD5/penguin/7183.png"
}
```

It is because the image is stored at IPFS's server(s), and our web browser won't process the `ipfs://` protocol as it does to `https://`. We need an "gateway" to access it. [ipfs.io](https://ipfs.io/) is usually a good choice.

> For other choices, see [Public Gateways Checker](https://ipfs.github.io/public-gateway-checker/)

You need to append the content after `ipfs://` to the end of `https://ipfs.io/ipfs/` to get it:
```
https://ipfs.io/ipfs/QmNf1UsmdGaMbpatQ6toXSkzDpizaGmC9zfunCyoz1enD5/penguin/7183.png
```

[ipfs.io](https://ipfs.io/) may go down. But IPFS itself is unlikely to. For the reason, please refer to [IPFS Docs](https://docs.ipfs.tech/concepts/lifecycle/#_1-content-addressing-merkleizing). Simply put, it is like bittorrent: as long as there is a copy in the IPFS network, you can get it.

## Deploy my own NFT

### Preparation

node 18 and yarn are required for this demo
```
nvm install 18
nvm use 18
npm install -g yarn
```

Install dependencies
```
yarn install 
```

### Project structure

- `contracts`
    - `RandomIpfsNft.sol`
- `scripts`
    - `01-deploy-random-ipfs-nft.js`
    - `02-mint.js`
- `assets`
    - Dog images
    - NFT config json

### Test it on local node

```
npx hardhat run .\scripts\01-deploy-random-ipfs-nft.js --network hardhat
npx hardhat run .\scripts\02-mint.js --network hardhat
```

### Pin (upload) files to IPFS using Pinata

0. Create an account at [Pinata](https://app.pinata.cloud/ipfs/files)
1. Upload the images (I have done it for you, see [this](https://ipfs.io/ipfs/bafybeig4k7qfzkwguc5ldjj22lodnujmqoo5cnmg66dtlt3jl6khqqdq7e/))
2. Edit the `image` URI in the json files, and upload them too (I have done it for you, see [this](https://ipfs.io/ipfs/bafybeig4k7qfzkwguc5ldjj22lodnujmqoo5cnmg66dtlt3jl6khqqdq7e/))
3. Copy paste json IPFS URI to Line 14 `tokenUris` in `01-deploy-random-ipfs-nft.js`

### Create Chainlink VRF Subscription

0. [Get some Sepolia Ether](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)
0. [Get some Sepolia LINK](https://faucets.chain.link/sepolia)
0. [Get `SEPOLIA_API_URL` and `SEPOLIA_PRIVATE_KEY`](https://dashboard.alchemy.com/)
1. Go to https://vrf.chain.link/
2. Choose Sepolia test net
3. Create subscription, check and confirm transaction
4. Add fund to the subscription, check and confirm transaction
5. Copy paste `Key hash`, `VRF Coordinator` address and `subscription ID` to Line 11 `gas_lane`, Line 39 `vrfCoordinatorV2Address` and 40 `subscriptionId` in `01-deploy-random-ipfs-nft.js`

### Deploy contracts on Sepolia and add VRF Consumer

```
npx hardhat run .\scripts\01-deploy-random-ipfs-nft.js --network sepolia
```
You will get output like
```
Deploying contracts with the account: 0x2754f28BA6c367d58a2cDDaF72b010140Dd4989D
Deploying contracts to chainid: 84532
NFT Contract is Deployed at:  0x45E9f58569d46aAb2e7891d77d282Eadc380E8E9
```
Then update the consumer address at [Chainlink VRF](https://vrf.chain.link/)

Also update the contract address at `02-mint.js`

### Mint an NFT

```
npx hardhat run .\scripts\02-mint.js --network base_sepoli
```

And go to [blockchain explorer](https://sepolia.basescan.org/address/0x2754f28BA6c367d58a2cDDaF72b010140Dd4989D), you can find [the NFT you just mint](https://sepolia.basescan.org/token/0x45e9f58569d46aab2e7891d77d282eadc380e8e9).

Go back to [Chainlink VRF](https://vrf.chain.link/), you will find the fulfillment plus 1.

Go to [test net opensea](https://testnets.opensea.io/), and check [if our RIN collection is up](https://testnets.opensea.io/collection/random-ipfs-nft-190).

You can also mint a lot (as you as you have enough ether to pay gas and enough LINK to pay VRF fee) to check if the randomness works.