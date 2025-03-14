// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721, ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title RandomIpfsNft
 * @dev This contract allows users to mint random NFTs based on a Chainlink VRF-derived random number.
 * Each NFT represents a different breed of dog, and the breed is determined by the randomness provided.
 */
contract RandomIpfsNft is ERC721URIStorage, VRFConsumerBaseV2Plus {
    // Key hash for gas lane
    bytes32 immutable i_gasLane;

    // Chainlink subscription ID
    uint256 immutable i_subscriptionId;

    // Gas limit for the callback function
    uint32 immutable i_callBackGasLimit;

    // Constants for random number generation
    uint16 constant REQUEST_CONFIRMATIONS = 3;
    uint32 constant NUM_WORDS = 1;
    uint256 constant MAX_CHANCE_VALUE = 100;

    // Mapping from request ID to the address of the requester
    mapping (uint256 => address) s_requestIdToSender;

    // IPFS URIs for different dog breeds
    string[3] s_dogTokenUris;

    // Counter for minted tokens
    uint256 s_tokenCounter;

    /**
     * @dev Constructor to initialize the contract with necessary parameters.
     * @param vrfCoordinatorV2 Address of the VRF Coordinator contract
     * @param gasLane Key hash for gas lane
     * @param subscriptionId Subscription ID for Chainlink VRF
     * @param callBackGasLimit Gas limit for the callback function
     * @param dogTokenUris Array of URIs for different dog breeds
     */
    constructor(
        address vrfCoordinatorV2, 
        bytes32 gasLane, 
        uint256 subscriptionId,
        uint32 callBackGasLimit,
        string[3] memory dogTokenUris
    ) 
        ERC721("Random IPFS NFT", "RIN") 
        VRFConsumerBaseV2Plus(vrfCoordinatorV2)
    {
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callBackGasLimit = callBackGasLimit;
        s_tokenCounter = 0;
        s_dogTokenUris = dogTokenUris;
    }

    /**
     * @dev Requests a random dog minting.
     * @return requestId The request ID for the random number generation
     */
    function requestDoggie() public returns (uint256 requestId) {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gasLane,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callBackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        s_requestIdToSender[requestId] = msg.sender;
    } 

    /**
     * @dev Callback function used by VRF Coordinator to return the random number.
     * @param requestId The ID of the request
     * @param randomWords The array of random words generated
     */
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        // Owner of the dog NFT
        address dogOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter = s_tokenCounter + 1;

        // Get the breed from the random number
        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
        uint256 breed = getBreedFromModdenRng(moddedRng);

        // Mint the NFT and set its token URI
        _safeMint(dogOwner, newTokenId);
        _setTokenURI(newTokenId, s_dogTokenUris[breed]);
    }

    /**
     * @dev Generates an array representing the chances for each breed of dog.
     * @return An array containing the cumulative chances for different breeds
     */
    function getChanceArray() public pure returns(uint256[3] memory) {
        // 0 - 9 = brown
        // 10 - 29 = yellow
        // 30 - 99 = black
        return [10, 20, MAX_CHANCE_VALUE];
    }

    /**
     * @dev Determines the breed of the dog based on the generated random number.
     * @param moddendRng The random number modded to the maximum chance value
     * @return The index of the breed
     */
    function getBreedFromModdenRng(uint256 moddendRng) private pure returns(uint256) {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();
        uint256 i;
        
        for (i = 0; i < chanceArray.length; i++) {
            if (moddendRng >= cumulativeSum && moddendRng < cumulativeSum + chanceArray[i]) {
                break;
            }
            cumulativeSum = cumulativeSum + chanceArray[i];
        }
        return i;
    }
}