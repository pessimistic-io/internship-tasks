// This code snippet is provided by Pessimistic company.
// To apply for the internship opportunity at Pessimistic company,
// please fill out the form by visiting the following link: https://forms.gle/SUTcGi8X86yNoFnG7

// Caution: This code is intended for educational purposes only
// and should not be used in production environments.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import {OracleLibrary} from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

contract PriceGetter {
    uint256 public number;

    address public immutable usdc;
    address public constant DAI_USDC_UNI_V3_POOL = 0xF0428617433652c9dc6D1093A42AdFbF30D29f74;
    address public constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    uint32 internal constant TWAP_SECONDS = 1800;

    constructor(address _usdc) {
        usdc = _usdc;
    }

    function daiToUsdc(uint256 daiAmount) public view returns (uint256) {
        (int24 meanTick, ) = OracleLibrary.consult(
            DAI_USDC_UNI_V3_POOL,
            TWAP_SECONDS
        );
        return
            OracleLibrary.getQuoteAtTick(
                meanTick,
                uint128(daiAmount),
                DAI,
                usdc
            );
    }
}
