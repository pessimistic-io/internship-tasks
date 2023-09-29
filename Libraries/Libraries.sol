// This code snippet is provided by Pessimistic company.
// To apply for the internship opportunity at Pessimistic company,
// please fill out the form by visiting the following link: https://forms.gle/SUTcGi8X86yNoFnG7

// Caution: This code is intended for educational purposes only
// and should not be used in production environments.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

library Items {
    using Items for ItemId;

    struct ItemId {
        bytes4 class;
        bytes data;
    }

    struct Item {
        ItemId id;
        uint256 value;
    }

    function token(ItemId memory self) internal pure returns (address) {
        return abi.decode(self.data, (address));
    }

    function hash(Items.ItemId[] memory itemIds) internal pure returns (bytes32) {
        return keccak256(abi.encode(itemIds));
    }

    function deposit(
        Items.Item memory item,
        uint256 amount
    ) external {
        address itemToken = item.id.token();

        IERC20(itemToken).transferFrom(msg.sender, address(this), amount);
    }
}

library Placements {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using Items for Items.Item;

    struct Placement {
        Items.Item[] items;
        address sender;
        address beneficiary;
        uint32 deadline;
        uint256 fee;
    }

    struct Registry {
        CountersUpgradeable.Counter placementIdTracker;
        mapping(uint256 => Placement) placements;
    }

    function register(Registry storage self, Placement memory placement) external returns (uint256 placementId) {
        self.placementIdTracker.increment();

        Placement storage placementRecord = self.placements[placementId];

        placementRecord.sender = placement.sender;
        placementRecord.beneficiary = placement.beneficiary;
        placementRecord.deadline = placement.deadline;

        for (uint256 i = 0; i < placement.items.length; i++) {
            placementRecord.items.push(placement.items[i]);
            placement.items[i].deposit(placement.fee);
        }
    }
}

abstract contract ManagerStorage {
    Placements.Registry internal _placementRegistry;
}
