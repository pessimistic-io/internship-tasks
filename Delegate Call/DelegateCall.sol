// This code snippet is provided by Pessimistic company.
// To apply for the internship opportunity at Pessimistic company,
// please fill out the form by visiting the following link: https://forms.gle/SUTcGi8X86yNoFnG7

// Caution: This code is intended for educational purposes only
// and should not be used in production environments.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IController {
    function transferAssetToVault(address token, address assetOwner, address vault,
     uint256 tokenId) external;
}

interface IMetahub {
    function deposit(address from, uint256 tokenId) external;
}

library Assets {
    using Address for address;

    struct AssetConfig {
        address controller;
        address vault;
    }
    struct Registry {
        address token;
        mapping(address => AssetConfig) assets;
    }

    function transferAssetToVault(Registry storage self, address from, uint256 tokenId) external {
        address vault = self.assets[self.token].vault;
        address controller = address(self.assets[self.token].controller);
        controller.functionDelegateCall(abi.encodeWithSelector(IController.transferAssetToVault.selector, self.token, from, vault, tokenId));
    }

    function registerData(Registry storage self, address token, address vault, address controller) external {
        if (self.assets[token].vault == address(0)) {
            self.token = token;
            self.assets[token].vault = vault;
            self.assets[token].controller = controller;
        }
    }
}

contract Manager {
    address internal _metahub;

    constructor(address metahubContract) {
        _metahub = metahubContract;
    }

    function deposit(uint256 tokenId) external {
        IMetahub(_metahub).deposit(msg.sender, tokenId);
    }
}

contract Metahub is IMetahub, Ownable {
    using Assets for Assets.Registry;

    address internal _managerContract;
    Assets.Registry internal _assetRegistry;

    modifier onlyManager() {
        require(msg.sender == _managerContract);
        _;
    }

    constructor(address manager) {
        _managerContract = manager;
    }

    function setAssetRegistryData(address token, address vault, address controller) onlyOwner external {
        _assetRegistry.registerData(token, vault, controller);
    }

    function deposit(address from, uint256 tokenId) onlyManager external {
        _assetRegistry.transferAssetToVault(from, tokenId); 
    }
}


contract Controller is IController {
    address private immutable __self = address(this);
    error FunctionMustBeCalledThroughDelegatecall();

    modifier onlyDelegatecall() {
        if (address(this) == __self) revert FunctionMustBeCalledThroughDelegatecall();
        _;
    }

	function transferAssetToVault(address token, address assetOwner, address vault, uint256 tokenId) onlyDelegatecall external {
		_transferAsset(token, assetOwner, vault, tokenId);
	}

	function _transferAsset(address token, address from, address to, uint256 tokenId) internal {
		IERC721(token).transferFrom(from, to, tokenId);
	}
}

contract Vault {

    address _metahub;

    mapping(address => mapping(uint256 => address)) private owner;

    modifier whenAssetDepositAllowed(address operator) {
        require(operator == _metahub);
        _;
    }

    constructor(address metahubContract) {
        _metahub = metahubContract;
    }

    function onERC721Received(address operator, address from, uint256 tokenID) 
    whenAssetDepositAllowed(operator) external returns (bytes4) {
		owner[msg.sender][tokenID] = from;
        return this.onERC721Received.selector;
	}
}

