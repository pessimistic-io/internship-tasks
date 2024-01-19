// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Token.sol";


contract Distribution is Ownable, AccessControl, ReentrancyGuard {
    Token public token;

    uint256 public start;
    uint256 public constant LONG = 50 days;
    uint256 public constant MEDIUM = 30 days;
    uint256 public constant SHORT = 20 days;
    uint256 public constant SHORT_CLIFF = 2 days;

    event ClaimTokens(address beneficiary, uint256 amount);

    struct Info {
        uint32 provided;
        uint256 claimed;
        uint32 long;
        uint32 medium;
        uint32 short;
    }
    mapping(address => Info) public accountInfo;

    constructor(address _tokenAddress) {
        token = Token(_tokenAddress);
        start = block.timestamp;
    }

    function claimTokens() external nonReentrant {
        require(block.timestamp >= start, "The distribution hasn't started yet");
        uint256 availableTokens = _claimableTokens(msg.sender);
        require(availableTokens > 0, "You don't have any tokens to claim");
        Info storage _info = accountInfo[msg.sender];
        _info.claimed = _info.claimed + availableTokens;
        token.mint(msg.sender, availableTokens);

        emit ClaimTokens(msg.sender, availableTokens);
    }

    function setStart(uint256 _start) external onlyOwner {
        require(start < block.timestamp, "The token distribution has already started");
        start = _start;
    }

    function setAccountsInfo(
        address[] memory accounts,
        uint32[] memory long,
        uint32[] memory medium,
        uint32[] memory short,
        uint32[] memory claimed
    ) external onlyOwner {
        for (uint8 i = 0; i < accounts.length; i++) {
            uint32 _provided = long[i] + medium[i] + short[i];
            accountInfo[accounts[i]] = Info(
                _provided,
                uint256(claimed[i]) * 10 ** 18,
                long[i],
                medium[i],
                short[i]
            );
        }
    }

    function claimableTokens(address _account) external view returns (uint256) {
        return _claimableTokens(_account);
    }

    function claimedTokens(address _account) external view returns (uint256) {
        return accountInfo[_account].claimed;
    }

    function vestedTokens(address _account) external view returns (uint256) {
        return _vestedTokens(_account);
    }

    function info(address _account) external view returns (uint256, uint256, uint256, uint256, uint256) {
        Info memory _info = accountInfo[_account];
        return (
            _info.provided * 10 ** 18,
            _info.claimed,
            _info.long * 10 ** 18,
            _info.medium * 10 ** 18,
            _info.short * 10 ** 18
        );
    }

    function _claimableTokens(address _account) private view returns (uint256 claimableAmount) {
        uint256 vestedAmount = _vestedTokens(_account);
        uint256 claimed = accountInfo[_account].claimed;
        if (vestedAmount <= claimed) {
            claimableAmount = 0;
        } else {
            claimableAmount = vestedAmount - claimed;
        }
    }

    function _vestedTokens(address _account) private view returns (uint256 vestedAmount) {
        if (block.timestamp <= start) return 0;
        Info memory _info = accountInfo[_account];
        uint256 timeElapsed = block.timestamp - start;

        if (timeElapsed >= LONG) {
            vestedAmount += uint256(_info.long) * 10 ** 18;
        } else {
            vestedAmount += (_info.long * timeElapsed * 10 ** 18) / LONG;
        }
        if (timeElapsed >= MEDIUM) {
            vestedAmount += uint256(_info.medium) * 10 ** 18;
        } else {
            vestedAmount += (_info.medium * timeElapsed * 10 ** 18) / MEDIUM;
        }
        if (timeElapsed >= SHORT) {
            vestedAmount += uint256(_info.short) * 10 ** 18;
        } else {
            if (timeElapsed < SHORT_CLIFF) {
                vestedAmount += (uint256(_info.short) * 10 ** 17);
            } else {
                vestedAmount += (_info.short * timeElapsed * 10 ** 18) / SHORT;
            }
        }
    }
}
