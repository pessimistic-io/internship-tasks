// This code snippet is provided by Pessimistic company.
// To apply for the internship opportunity at Pessimistic company,
// please fill out the form by visiting the following link: https://forms.gle/SUTcGi8X86yNoFnG7

// Caution: This code is intended for educational purposes only
// and should not be used in production environments.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Airdrop {
    using MerkleProof for bytes32[];
    using SafeERC20 for IERC20;

    bytes32 private _merkleTreeRoot;

    IERC20 private _erc20;

    event Claim(address indexed who, uint256 amount);

    constructor(IERC20 erc20, bytes32 merkleTreeRoot) {
        _erc20 = erc20;
        _merkleTreeRoot = merkleTreeRoot;
    }

    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(_erc20.balanceOf(msg.sender) == 0);
        require(proof.verify(_merkleTreeRoot, keccak256(abi.encode(msg.sender))), "User was not found");
        
        _erc20.safeTransfer(msg.sender, amount);

        emit Claim(msg.sender, amount);
    }
}