// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

//import the AggregatorV3Interface from Chainlink
/*
    The price of $URB is always brought back to $1
    Urbane Stablecoin Smart Contract Addresses : 
    USDT : 0xD839328B206551FFE4F878BB290E88a8E6d88E03
    WETH : 0x8641c2a2c9C7781cA6c22F640B499740fdF41f31
    Urbane Reserve : 0x92F6Ea8b0D1ec8DC32A28093557CbA11dc4b336B
    Price Oracle : 0xF021cba923Db7a57fDeEcA3Ce71539479388CB96
    Urbane Stablecoin : 0x3DCbFaE5F248b23ca9c3536D4fC04615e3864867
    Governance : 0xE1AD3ed831BDC1D6218B6E9e864fb40Ab503B4fB
 */
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract PriceOracle{
    AggregatorV3Interface private priceOracle;
    int256 public unstableColPrice; 
    address public dataFeed;

    //set the price feed oracle address
    function setDataFeedAddress(address contractAddress) external{
        dataFeed = contractAddress;
        priceOracle = AggregatorV3Interface(dataFeed);
    }

    //get the data of the Ethereum price from the price feed and convert to WEI
    function colPriceInWei() external{
        (,int256 price, , ,) = priceOracle.latestRoundData();
        unstableColPrice = price * (1e10);
    }

    //get the data of the Ethereum price in its raw form
    function rawColPrice() external view returns(int256){
        (,int256 price, , ,) = priceOracle.latestRoundData();
        return price;
    }
}