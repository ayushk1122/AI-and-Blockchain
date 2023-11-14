// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract krisha7_Task3RollDice is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;

    /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: Sepolia
     * Chainlink VRF Coordinator address: [VRF Coordinator Address for Sepolia]
     * LINK token address: 0x779877A7B0D9E8603169DdbD7836e478b4624789
     * Key Hash: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c
     */
    constructor() 
        VRFConsumerBase(
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625, // VRF Coordinator
            0x779877A7B0D9E8603169DdbD7836e478b4624789  // LINK Token
        ) public
    {
        keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
        fee = 0.25 * 10 ** 18; // 0.25 LINK
    }

    /**
     * Requests randomness
     */
    function roll() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = (randomness % 6) + 1; // Number between 1 and 6
    }
}
