// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import {Test} from "forge-std/Test.sol";
import {PriceGetter} from "../src/PriceGetter.sol";

contract PriceGetterTest is Test {
    PriceGetter public priceGetter;
    uint256 internal constant daiDecimals = 18;
    uint256 internal constant usdcDecimals = 6;

    function setUp() public {
        priceGetter = new PriceGetter(0xaf88d065e77c8cC2239327C5EDb3A432268e5831);
    }

    function test_DaiToWant() public {
        uint256 price = priceGetter.daiToUsdc(10 ** daiDecimals);
        assertGt(price, 9 * 10 ** (usdcDecimals - 1));  // price > 0.9$
        assertLt(price, 11 * 10 ** (usdcDecimals - 1));  // price < 1.1$
    }
}
