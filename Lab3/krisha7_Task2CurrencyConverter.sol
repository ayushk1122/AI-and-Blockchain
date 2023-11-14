// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract krisha7_Task2CurrencyConverter {
    AggregatorV3Interface internal dataFeed;

    /**
     * Network: [Appropriate Network]
     * Aggregator: GBP/USD
     * Address: /* Your GBP/USD Data Feed Address */
    constructor() {
        dataFeed = AggregatorV3Interface(
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        );
    }

    /**
     * Returns the latest GBP/USD rate.
     */
    function getLatestGBPUSD() public view returns (int) {
        (
            /* uint80 roundID */,
            int answer,
            /* uint startedAt */,
            /* uint timeStamp */,
            /* uint80 answeredInRound */
        ) = dataFeed.latestRoundData();
        return answer;
    }

    /**
     * Converts GBP to USD.
     */
    function convertGBPtoUSD(int gbpAmount) public view returns (int) {
        int rate = getLatestGBPUSD();
        return gbpAmount * rate;
    }
}
