AI and Blockchain Lab03 - Web3 and Oracles

Task 2 Deployed Address: 0x4ee038cad20d21dedf81f808c6fb1eb0023859b3
Task 3 Deployed Address: 0xc521e3ba68bbd2699ec73e3e3f0c07e426427733
Task 4:
Cryptic error: [block:4674525 txIndex:3]from: 0x600...9f11fto: krisha7_Task4Pokemon.(constructor)value: 0 weidata: 0x608...70033logs: 0hash: 0xb44...30490
Compiles fully and contract seems to be deployable but recieve this error as described in the email
Contract code:
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract krisha7_Task4Pokemon is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    using Strings for uint256;

    // Define state variables
    uint256 public pokemonHeight;
    uint256 public pokemonWeight;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    /**
     * Network: Sepolia
     * Oracle: 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD
     * Job ID: 7da2702f37fd48e5b1b9a5715e3509b6
     * Fee: 0.1 LINK
     */
    constructor() {
        setPublicChainlinkToken();
        oracle = 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD;
        jobId = "7da2702f37fd48e5b1b9a5715e3509b6";
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target data.
     */
    function requestPokemonData() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Set the URL to perform the GET request on
        request.add("get", "https://pokeapi.co/api/v2/pokemon?limit=1");
        request.add("path", "results.0.url"); // Modify the path to navigate the JSON response

        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    /**
     * Receive the response in the form of uint256
     */ 
    function fulfill(bytes32 _requestId, uint256 _height, uint256 _weight) public recordChainlinkFulfillment(_requestId) {
        pokemonHeight = _height;
        pokemonWeight = _weight;
    }
}



