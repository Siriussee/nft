# ChainLink VRF NFT Project Documentation

This document serves as a comprehensive guide for deploying and interacting with a sample NFT project using ChainLink VRF for verifiable randomness.

## Table of Contents

1. [Understanding NFTs](#1-understanding-nfts)
2. [Storing NFT Assets](#2-storing-nft-assets)
   - [Centralized Storage](#centralized-storage)
   - [Decentralized Storage](#decentralized-storage)
3. [Project Setup and Structure](#3-project-setup-and-structure)
4. [Configuring Testnet RPC and Private Key](#4-configuring-testnet-rpc-and-private-key)
5. [Uploading Files to IPFS using Pinata](#5-uploading-files-to-ipfs-using-pinata)
6. [Configuring ChainLink VRF Subscription](#6-configuring-chainlink-vrf-subscription)
7. [Deploying Contracts on Sepolia](#7-deploying-contracts-on-sepolia)
8. [Minting an NFT](#8-minting-an-nft)

---

## 1. Understanding NFTs

Before proceeding, please review the [ERC-721: Non-Fungible Token Standard](https://eips.ethereum.org/EIPS/eip-721).

---

## 2. Storing NFT Assets

NFTs typically include metadata and images that must be stored and accessed reliably. Two popular options are centralized servers (e.g., AWS S3) and decentralized protocols (e.g., IPFS).

### Centralized Storage

For instance, visit [OpenSea](https://opensea.io/), choose a random NFT collection, and select an NFT. Consider the example of [Fidenza #956](https://opensea.io/assets/ethereum/0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270/78000956).

From the NFT details, the contract and token information is:

- **Contract Address:** `0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270`
- **Token ID:** `78000956`

Access additional details using these links:
- [Contract Address on Etherscan](https://etherscan.io/address/0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270#readContract)
- [NFT URI](https://token.artblocks.io/78000956)

Within the NFT metadata, you might find an entry such as:

```json
{
    "primary_asset_url": "https://media-proxy.artblocks.io/0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270/78000956.png"
}
```

This URL points to an asset stored in an Amazon S3 bucket.

### Decentralized Storage

Using a decentralized approach ensures higher availability. Consider the example of [Pudgy Penguin #7183](https://opensea.io/assets/ethereum/0xbd3531da5cf5857e7cfaa92426877b022e612cf8/7183). The token URI for this NFT returns metadata similar to:

```json
{
  "attributes": [
    { "trait_type": "Background", "value": "Blue" },
    { "trait_type": "Skin", "value": "Light Gray" },
    { "trait_type": "Body", "value": "Apron" },
    { "trait_type": "Face", "value": "Cross Eyed" },
    { "trait_type": "Head", "value": "Party Hat" }
  ],
  "description": "A collection 8888 Cute Chubby Pudgy Penguens sliding around on the freezing ETH blockchain.",
  "image": "ipfs://QmNf1UsmdGaMbpatQ6toXSkzDpizaGmC9zfunCyoz1enD5/penguin/7183.png",
  "name": "Pudgy Penguin #7183"
}
```

To view the image stored on IPFS, replace the `ipfs://` prefix with a gateway URL. The recommended gateway is [ipfs.io](https://ipfs.io/). For example, modify the URI as follows:
https://ipfs.io/ipfs/QmNf1UsmdGaMbpatQ6toXSkzDpizaGmC9zfunCyoz1enD5/penguin/7183.png

Note that the availability of services like [ipfs.io](https://ipfs.io/) can change over time; refer to the [Public Gateways Checker](https://ipfs.github.io/public-gateway-checker/) for alternatives. For more details on IPFS, see the [IPFS Docs](https://docs.ipfs.tech/concepts/lifecycle/#_1-content-addressing-merkleizing).

---

## 3. Project Setup and Structure

### Prerequisites

Ensure that you have Node.js version 18 and Yarn installed:

```bash
nvm install 18
nvm use 18
npm install -g yarn
```

### Installing Dependencies

After cloning the project repository, install the required packages:

```bash
yarn install 
```

### Directory Structure

The project follows this structure:

- **contracts**
  - `RandomIpfsNft.sol`
- **scripts**
  - `01-deploy-random-ipfs-nft.js`
  - `02-mint.js`
- **assets**
  - Dog images
  - NFT configuration JSON files

---

## 4. Configuring Testnet RPC and Private Key

1. Obtain your `SEPOLIA_API_URL` and `SEPOLIA_PRIVATE_KEY` from [Alchemy Dashboard](https://dashboard.alchemy.com/).
2. Create a `.env` file following the `.env-sample` file
3. Update network settings `hardhat.config.js`. I am using base sepolia as my test network, so it should be
```javascript
networks: {
  base_sepolia: {
    chainId: 84532,
    url: process.env.SEPOLIA_API_URL,
    accounts: [process.env.SEPOLIA_PRIVATE_KEY]
  }
}

```
In case you are using hardhat or Ethereum Sepolia as test network
```javascript
networks: {
  hardhat: {
    chainId: 31337,
    blockConformations: 1,
    allowUnlimitedContractSize: true
  },
  sepolia: {
    chainId: 11155111,
    url: process.env.SEPOLIA_API_URL,
    accounts: [process.env.SEPOLIA_PRIVATE_KEY]
  }
}
```

---

## 5. Uploading Files to IPFS using Pinata

Follow these steps to pin your files to IPFS using Pinata:

1. Create an account on [Pinata](https://app.pinata.cloud/ipfs/files).
2. Upload your NFT images. (For example, the images are already available at [this link](https://ipfs.io/ipfs/bafybeig4k7qfzkwguc5ldjj22lodnujmqoo5cnmg66dtlt3jl6khqqdq7e/).)
3. Edit the JSON metadata files to update the `image` URI accordingly, then upload them. (Pre-uploaded JSONs are available [here](https://ipfs.io/ipfs/bafybeig4k7qfzkwguc5ldjj22lodnujmqoo5cnmg66dtlt3jl6khqqdq7e/).)
4. Replace the placeholder URI in the `tokenUris` array on line 14 of `01-deploy-random-ipfs-nft.js` with the new JSON metadata URI.

---

## 6. Configuring ChainLink VRF Subscription

Before deploying contracts to a testnet, set up a ChainLink VRF subscription:

1. Obtain some Sepolia Ether from [this faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia).
2. Get Sepolia LINK tokens from [this faucet](https://faucets.chain.link/sepolia).
4. Navigate to [ChainLink VRF](https://vrf.chain.link/) and choose the Sepolia test network.
5. Create a new subscription and confirm the transaction.
6. Fund your subscription, then note down the following details:
   - **Key Hash:** (to be pasted into `gas_lane` on line 11 of `01-deploy-random-ipfs-nft.js`)
   - **VRF Coordinator Address:** (to be used on line 39 as `vrfCoordinatorV2Address`)
   - **Subscription ID:** (to be used on line 40 as `subscriptionId`)

---

## 7. Deploying Contracts on Sepolia

Deploy the NFT smart contract with the following command:

```bash
npx hardhat run ./scripts/01-deploy-random-ipfs-nft.js --network base_sepolia
```

Sample output:
```
Deploying contracts with the account: 0x2754f28BA6c367d58a2cDDaF72b010140Dd4989D
Deploying contracts to chainid: 84532
NFT Contract is Deployed at: 0x45E9f58569d46aAb2e7891d77d282Eadc380E8E9
```
After deployment, update the consumer address in your ChainLink VRF subscription details via [ChainLink VRF](https://vrf.chain.link/).

Also, make sure to update the contract address in `02-mint.js`.

---

## 8. Minting an NFT

Mint a new NFT on the testnet using this command:

```bash
npx hardhat run ./scripts/02-mint.js --network base_sepolia
```

After minting, verify the NFT on a blockchain explorer. For example, check the deployed NFT at:
- [Blockchain Explorer - Sepolia BaseScan](https://sepolia.basescan.org/address/0x2754f28BA6c367d58a2cDDaF72b010140Dd4989D)
- [NFT Token on BaseScan](https://sepolia.basescan.org/token/0x45e9f58569d46aab2e7891d77d282eadc380e8e9)

Return to [ChainLink VRF](https://vrf.chain.link/) to view the fulfillment count and verify that it has incremented.

Additionally, check [Testnet OpenSea](https://testnets.opensea.io/) to see if your "RIN" NFT collection is listed: [Random IPFS NFT Collection](https://testnets.opensea.io/collection/random-ipfs-nft-190).

Feel free to mint multiple NFTs if you have sufficient Ether for gas and LINK for VRF fees to test the randomness mechanism.
