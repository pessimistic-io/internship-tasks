// This code snippet is provided by Pessimistic company.
// To apply for the internship opportunity at Pessimistic company,
// please fill out the form by visiting the following link: https://forms.gle/SUTcGi8X86yNoFnG7

// Caution: This code is intended for educational purposes only
// and should not be used in production environments.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vesting {
    event TokenReleased(
        address indexed account,
        address indexed token,
        uint256 amount
    );

    struct Info {
        uint256 locked;
        uint256 released;
    }

    address public immutable token;
    uint256 public immutable startTimestamp;
    uint256 internal cliffDuration;
    uint256 internal vestingDuration;

    mapping(address => Info) internal _vesting;

    /**
     * @notice constructor
     * @param token_ - token address
     * @param cliffMonthDuration - cliff duration in months
     * @param vestingMonthDuration - vesting duration in months
     * @param accounts - vesting accounts
     * @param amounts - vesting amounts of accounts
     **/
    constructor(
        address token_,
        uint256 cliffMonthDuration,
        uint256 vestingMonthDuration,
        address[] memory accounts,
        uint256[] memory amounts
    ) {
        startTimestamp = uint64(block.timestamp);

        token = token_;
        cliffDuration = cliffMonthDuration * 4 weeks;
        vestingDuration = vestingMonthDuration * 4 weeks;

        for (uint256 i = 0; i < accounts.length; i++) {
            _vesting[accounts[i]] = Info({locked: amounts[i], released: 0});
        }
    }

    function release() external {
        //add history by block
        address sender = msg.sender;

        require(
            block.timestamp > startTimestamp + cliffDuration,
            "cliff period has not ended yet."
        );

        Info storage vestingInfo = _vesting[sender];
        uint256 amountByMonth = vestingInfo.locked /
            (vestingDuration + cliffDuration);

        uint256 releaseAmount = ((block.timestamp - startTimestamp) / 4 weeks) *
            amountByMonth -
            vestingInfo.released;

        require(releaseAmount > 0, "not enough release amount.");

        vestingInfo.released += releaseAmount;
        SafeERC20.safeTransfer(IERC20(token), sender, releaseAmount);
    }
}