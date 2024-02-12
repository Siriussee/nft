// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
pragma solidity ^0.8.19;
contract RandomIpfsNft is ERC721URIStorage, VRFConsumerBaseV2 {

    VRFCoordinatorV2Interface immutable i_vrfCoordinator;
    bytes32 immutable i_gasLane;
    uint64 immutable i_subscriptionId;
    uint32 immutable i_callBackGasLimit;

    uint16 constant REQUEST_CONFIRMATIONS = 3;
    uint32 constant NUM_WORDS = 1;
    uint256 constant MAX_CHANCE_VALUE = 100;

    mapping (uint256=>address) s_requestIdToSender;
    string[3] s_dogTokenUris;

    uint256 s_tokenCounter;

    constructor(
        address vrfCoordinatorV2, 
        bytes32 gasLane, 
        uint64 subscriptionId,
        uint32 callBackGasLimit,
        string[3] memory dogTokenUris
    ) ERC721 ("Random IPFS NFT", "RIN") VRFConsumerBaseV2(vrfCoordinatorV2){
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callBackGasLimit = callBackGasLimit;
        s_tokenCounter = 0;
        s_dogTokenUris = dogTokenUris;
            // 0 = st.Bernard
            // 1 = Pug
            // 2 = Shiba inu

    }

    function requestDoggie() public returns (uint256 requestId) {
        requestId = i_vrfCoordinator.requestRandomWords (
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callBackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
    } 

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        //owner of the dog
        address dogOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter =s_tokenCounter + 1;
        // did we get a random dog?
        // is the st.bernard super random?
        // no, we need to fix it

        //randomWords = 2151846168646848786468
        //get the breed?
        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
        uint256 breed = getBreedFromModdenRng(moddedRng);

        _safeMint(dogOwner, newTokenId);
        _setTokenURI(newTokenId, s_dogTokenUris[breed]);
    }

    function getChanceArray() public pure returns(uint256[3] memory) {
        // 0 - 9 = st.bernard
        // 10 -29 = pug
        // 30 - 99 = shiba inu
        return [10, 30, MAX_CHANCE_VALUE];
    }

    function getBreedFromModdenRng(uint256 moddendRng) private pure returns(uint256)  {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();
        uint256 i;
        for(i = 0; i<chanceArray.length; i++) {
            if(moddendRng >=cumulativeSum && moddendRng < cumulativeSum + chanceArray[i]){
                break;
            }
            cumulativeSum = cumulativeSum + chanceArray[i];
        }
        return i;
    }
}