pragma solidity 0.8.16;

library FixedMath {
    uint256 constant ONE = 1e12;

    function mul(uint256 self, uint256 other) internal pure returns (uint256) {
        return (self * other) / ONE;
    }

    function div(uint256 self, uint256 other) internal pure returns (uint256) {
        return (self * ONE) / other;
    }

}

// There are two contracts: Treasury and TreasuryTree.
// The first one interacts with users - accepts deposits, stores and withdraws tokens,
// as well as distributes rewards and losses, which are somehow counted
// (in this case we will assume that it is not important).

// Treasury requests up-to-date information from TreasuryTree.
// That is, TreasuryTree stores information about all deposits
// and their updates, but does not store the tokens.

// The TreasuryTree is represented as a tree structure of segments.
// It consists of LEAVES_N nodes, where the root is node #1.
// The leaves of the segment tree are an array of values [LEAVES_0, LEAVES_N].
// The left child of node K can be computed as 2 * K, and the right child can be computed as 2 * K + 1.
// This contract does not store any tokens, it is just a way to account tokens and rewards. 
/*      +-----------------------------------------+
        |        1 (root)                         |
        +------------+----------------------------+
        |       2    |   3                        |
        +----+-------+-------+--------------------+
        | 4  |   5   |   6   |   0 (nextZeroNode) |
        +----+-------+-------+--------------------+
*/
// Each leaf is a deposit of some user. In this contract, we do not need to know
// how leaf numbers and user addresses relate. If the leaf amount is 0, it means
// that this deposit has already been withdrawn or this leaf has not been activated yet.
// Each parent node is the sum of its children nodes. So, the root is the sum of all current deposits.

contract TreasuryTree {
    using FixedMath for *;

    struct Node {
        uint64 updateId; // last update number
        uint128 amount; // node amount
    }

    uint48 constant LEAVES_0 = 1048576; // begining of data leaves, a root is #1 node
    uint48 constant LEAVES_N = LEAVES_0 * 2 - 1;

    uint48 public nextZeroNode; // next unused node number for deposit

    uint64 public updateId; // this number checks when a node has been updated. Note: a parent node may have more up-to-date information than its child node.

    // node number -> node info
    mapping(uint48 => Node) public nodeData;
    address treasury;

    error IncorrectAmount();
    error IncorrectLeaf();
    error LeafNotExist();
    error IncorrectPercent();

    modifier onlyTreasury() {
        require(msg.sender == treasury);
        _;
    }

    constructor (address _treasury) {
        nextZeroNode = LEAVES_0;
        updateId++;
        treasury = _treasury;
    }


    // distribute the profit among the [LEAVES_0, leaf] interval of users in proportion to their deposits

    function profitDistribution(uint128 profit, uint48 leaf) onlyTreasury external {
        require(profit != 0, "Amount should be > 0");
        if (leaf < LEAVES_0 || leaf > LEAVES_N)
            revert IncorrectLeaf();

        // push changes from the root down to the leaf
        _updateDown(1, LEAVES_0, LEAVES_N, leaf, ++updateId);

        _notFullyUpdate(
            1,
            LEAVES_0,
            LEAVES_N,
            LEAVES_0,
            leaf,
            profit,
            false,
            ++updateId
        );
    }

    /**
     * @dev changes node's amount by adding value or reducing value
     * @param node - node for changing
     * @param amount - amount value for changing
     * @param isSub - true - reduce by amount, false - add by amount
     * @param updateId_ - update number
     */
    function _updateNode(
        uint48 node,
        uint128 amount,
        bool isSub,
        uint64 updateId_
    ) internal {
        nodeData[node].updateId = updateId_;
        if (isSub) {
            if (nodeData[node].amount >= amount)
                nodeData[node].amount -= amount;
        } else {
            nodeData[node].amount += amount;
        }
    }

    /**
     * @dev add new deposit leaf for user
     * @param amount - adding amount
     * @return addedNodeId - leaf number of added deposit
     */
    function deposit(
        uint128 amount
    ) onlyTreasury external returns (uint48 addedNodeId) {
        require(amount != 0, "Amount should be > 0");
        _updateUp(nextZeroNode, amount, false, ++updateId);
        addedNodeId = nextZeroNode;
        nextZeroNode++;
    }

    /**
     * @dev withdraw part of deposit from the leaf
     * @dev it is needed firstly to update its amount and then withdraw
     * @dev used steps:
     * @dev 1 - push all changes from the root down to the leaf - that updates leaf's amount
     * @dev 2 - execute withdraw of leaf amount and update amount changing up to the root
     * @param leaf - leaf number
     * @param percent - percent of leaf amount 1*10^12 is 100%, 5*10^11 is 50%
     * @return withdrawAmount - withdrawn amount of the leaf according percent share
     */
    function withdraw(
        uint48 leaf,
        uint40 percent
    ) onlyTreasury external returns (uint128 withdrawAmount) {
        if (nodeData[leaf].updateId == 0) revert LeafNotExist();
        if (leaf < LEAVES_0 || leaf > LEAVES_N)
            revert IncorrectLeaf();
        if (percent > FixedMath.ONE) revert IncorrectPercent();

        // push changes from top node down to the leaf
        _updateDown(1, LEAVES_0, LEAVES_N, leaf, ++updateId);

        // remove amount (percent of amount) from leaf to it's parents
        withdrawAmount = uint128(nodeData[leaf].amount.mul(percent));
        _updateUp(leaf, withdrawAmount, true, ++updateId);
    }

    /**
     * @dev _updateDown changes from last "not fully update" down to leaf
     * @param node - last node from not fully update
     * @param start - leaf search start
     * @param end - leaf search end
     * @param leaf - last node to update
     * @param updateId_ update number
     */
    function _updateDown(
        uint48 node,
        uint48 start,
        uint48 end,
        uint48 leaf,
        uint64 updateId_
    ) internal {
        // if node is leaf, stop
        if (node == leaf) {
            return;
        }
        uint48 leftChild = node * 2;
        uint48 rightChild = node * 2 + 1;
        uint128 amount = nodeData[node].amount;
        uint256 lAmount = nodeData[leftChild].amount;
        uint256 sumChild = lAmount + nodeData[rightChild].amount;
        uint128 setLAmount = sumChild == 0
            ? 0
            : uint128((amount * lAmount) / sumChild);

        // update left and right child
        _setAmount(leftChild, setLAmount, updateId_);
        _setAmount(rightChild, amount - setLAmount, updateId_);

        uint48 mid = (start + end) / 2;

        if (start <= leaf && leaf <= mid) {
            _updateDown(leftChild, start, mid, leaf, updateId_);
        } else {
            _updateDown(rightChild, mid + 1, end, leaf, updateId_);
        }
    }

    /**
     * @dev _notFullyUpdate (not fully propagation) amount value from the root down to child nodes that contain leaves from LEAVES_0 to r
     * @param node - start update from node
     * @param start - left index of the binary search [start, end] interval
     * @param end - right index of the binary search [start, end] interval
     * @param l - left target interval index
     * @param r - right target interval index
     * @param amount - amount to add/reduce stored amounts
     * @param isSub - true means negative to reduce
     * @param updateId_ update number
     */
    function _notFullyUpdate(
        uint48 node,
        uint48 start,
        uint48 end,
        uint48 l,
        uint48 r,
        uint128 amount,
        bool isSub,
        uint64 updateId_
    ) internal {
        if ((start == l && end == r) || (start == end)) {
            // if node leafs equal to leaf interval then stop
            _updateNode(node, amount, isSub, updateId_);
            return;
        }

        uint48 mid = (start + end) / 2;

        if (start <= l && l <= mid) {
            if (start <= r && r <= mid) {
                // [l,r] in [start,mid] - all leaves in left child
                _notFullyUpdate(node * 2, start, mid, l, r, amount, isSub, updateId_);
            } else {
                // get left node's amount excluding unused leaves
                uint256 leftAmount = nodeData[node * 2].amount - _getIntervalSum(node * 2, start, mid, start, l - 1);
                // get right node's amount excluding unused leaves
                uint256 rightAmount = nodeData[node * 2 + 1].amount -
                    _getIntervalSum(node * 2 + 1, mid + 1, end, r + 1, end);
                uint256 sumChildren = leftAmount + rightAmount;
                uint128 deltaForLeftAmount = uint128(
                    (amount * leftAmount).div(sumChildren) / FixedMath.ONE
                );

                // l in [start,mid] - part in left child
                _notFullyUpdate(
                    node * 2,
                    start,
                    mid,
                    l,
                    mid,
                    deltaForLeftAmount,
                    isSub,
                    updateId_
                );

                // r in [mid+1,end] - part in right child
                _notFullyUpdate(
                    node * 2 + 1,
                    mid + 1,
                    end,
                    mid + 1,
                    r,
                    amount - deltaForLeftAmount,
                    isSub,
                    updateId_
                );
            }
        } else {
            // [l,r] in [mid+1,end] - all leaves in right child
            _notFullyUpdate(
                node * 2 + 1,
                mid + 1,
                end,
                l,
                r,
                amount,
                isSub,
                updateId_
            );
        }
        _updateNode(node, amount, isSub, updateId_);
    }

    /**
     * @dev reduce deposits from the [LEAVES_0, leaf] interval.
     * @param amount value to remove
     */
    function lossDistribution(uint128 amount, uint48 leaf) onlyTreasury external {
        require(amount != 0, "Amount should be > 0");
        if (leaf < LEAVES_0 || leaf > LEAVES_N)
            revert IncorrectLeaf();
        if (nodeData[1].amount >= amount) {

            // push changes from top node down to the leaf
            _updateDown(1, LEAVES_0, LEAVES_N, leaf, ++updateId);

            _notFullyUpdate(
                1,
                LEAVES_0,
                LEAVES_N,
                LEAVES_0,
                leaf,
                amount,
                true,
                ++updateId
            );
        }
    }

    /**
     * @dev set node amount, used in updateDown
     * @param node for set
     * @param amount value
     * @param updateId_ update number
     */
    function _setAmount(
        uint48 node,
        uint128 amount,
        uint64 updateId_
    ) internal {
        if (nodeData[node].amount != amount) {
            nodeData[node].updateId = updateId_;
            nodeData[node].amount = amount;
        }
    }

    /**
     * @dev update up amounts from leaf up to the root, used in deposit and withdraw
     * @param child node for update
     * @param amount value for update
     * @param isSub true - reduce, false - add
     * @param updateId_ update number
     */
    function _updateUp(
        uint48 child,
        uint128 amount,
        bool isSub,
        uint64 updateId_
    ) internal {
        _updateNode(child, amount, isSub, updateId_);
        // if not top parent
        if (child != 1) {
            uint48 parent = child == 1? 1: child / 2;
            _updateUp(parent, amount, isSub, updateId_);
        }
    }

    /**
     * @dev for current node get sum amount of exact leaves list
     * @param node node to get sum amount
     * @param start - node left element
     * @param end - node right element
     * @param l - left leaf of the list
     * @param r - right leaf of the list
     * @return amount sum of leaves list
     */
    function _getIntervalSum(
        uint48 node,
        uint48 start,
        uint48 end,
        uint48 l,
        uint48 r
    ) internal view returns (uint128 amount) {
        if ((start == l && end == r) || (start == end)) {
            // if a binary search interval is equal to the passed interval as parameters, then stop and return amount value
            return (nodeData[node].amount);
        }

        uint48 mid = (start + end) / 2;

        if (start <= l && l <= mid) {
            if (start <= r && r <= mid) {
                amount += _getIntervalSum(node * 2, start, mid, l, r);
            } else {
                amount += _getIntervalSum(node * 2, start, mid, l, mid);
                amount += _getIntervalSum(
                    node * 2 + 1,
                    mid + 1,
                    end,
                    mid + 1,
                    r
                );
            }
        } else {
            amount += _getIntervalSum(node * 2 + 1, mid + 1, end, l, r);
        }

        return amount;
    }
}
