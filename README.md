This set of tasks is part of the Pessimistic Junior Solidity smart contracts security educational initiative. Learn more here: https://medium.com/pessimistic-security/pessimistic-launches-junior-program-de0fcc4f4097

Solutions need to be posted to [gist](https://gist.github.com/) and sent to us as **individuall** links for each task! Send your solutions to [junior@pessimistic.io](junior@pessimistic.io), and we will publish and link to the best ones! In addition, we will invite you to the subsequent Pessimistic Junior!

The version in Russian language can be found [here](https://github.com/pessimistic-io/internship-tasks/blob/main/Tasks%20Description%20RUS.md).

## Vesting
Write a small description of how the code works.
You also need to write out the vulnerabilities, fix them in the code and send a corrected version of the code.

Note: you don't need to rewrite the whole code, it should be small edits.

## Vulnerable BEP20
You need to compare the implementation of **BEP20** token with [standard](https://github.com/bnb-chain/BEPs/blob/master/BEPs/BEP20.md) and write out the differences.

Example: If the implementation of the `approve` function does not meet the formal requirements of the standard, write this inconsistency as an issue. 
If it complies, write nothing.

## Libraries
Imagine that each contract is deployed separately. You need to understand the code and answer the following questions:
1. How is the `_placementRegistry` from the **ManagerStorage** contract initialized? (Write a mini-contract with 3 variants of initialization. For instance, you can design it as 3 functions).
2. Are the items at line 73 in the **Placements** contract added correctly? Why? (Give a detailed explanation).
3. What is the purpose of `using Items for ItemtId` in **Items** library? (Give an extended explanation and specify the line in the code).
4. How is the placement fee deducted? Who is it paid from and to whom? How are `msg.sender` and `address(this)` changed with each external call?  (Give a detailed explanation)

## Airdrop
You need to understand the code, write out issues and send a contract with fixes.

Note: you don't need to rewrite the whole code, it should be small edits.

## NFT
You need to figure out how to run [slither](https://github.com/crytic/slither) on this contract, and check the occurrences of all severity levels except `informational`. Write out all the ones you confirm (with your brief description/comment).

Important: occurrences for **OpenZeppelin** contracts do not need to be validated!

The following command can be used to run [slither](https://github.com/crytic/slither) (do not exclude **OpenZeppelin** contracts via flags, as some occurrences may not display):
```
slither . --solc-disable-warnings --exclude-informational
```

## Foundry task

You are given a `foundry` project. Your task is to install it, run tests on an **arbitrum** fork and explain why exactly they fail.

Please, send the following as a solution:

1. Results of the running test.
2. Why the test does not pass (use the `-vv` flag to get the detailed result). Describe the reason in detail.
3. Find a specific line in the code where calculations occur that were not expected when the test was written.

#### Tips and links

- documentation [foundry](https://book.getfoundry.sh/)

- It is recommended to run tests with the following command:

```solidity
forge test -vv --fork-url <your-arbitrum-rpc-url>
```

- you can get a free rpc for arbitrum [here](https://www.ankr.com/).

## Delegate Call
It is a complex chain of contract calls. You need to understand the code and answer the questions:

0. Which contract is the entry point?
1. Where in the code is the `onERC721Received` function from Vault called? You need to write out the call chain.
2. What are `address(this)` and `msg.sender` equal to when `Controller.transferAssetToVault` is called?
3. Will `require` of `modifier whenAssetDepositAllowed` (**Vault** contract) be reverted or not? Why?
4. Will `modifier onlyDelegatecall` from **Controller** contract correctly work out? Why?
5. How many contracts are being deployed? Which ones?

## King of the Ether

There is a game of King of the Ether:
- The contract is initialized with `1 ether` on the balance;
- The objective of the game is to make more `ether` than the other users.
- Each person has the right to add `ether` to the contract.
- 30 days after the contract is created, the game is considered to be over. And the person who has staked the most `ether` gets another `ether` as a reward.
- A person is not allowed to take out an `ether` until the game is over.
- When the game is over, each person can call the `withdraw` function to take his `ether`.

You need to write a contract for this game that is vulnerable to reentrancy, and also write an attacking contract.

## Vulnerable ERC20

You need to compare the implementation of **ERC20** token with [standard](https://eips.ethereum.org/EIPS/eip-20) and write out the differences.

Example: If the implementation of `approve` function does not meet the formal requirements of the standard, write out this inconsistency as an issue. 
If it complies, write out nothing.

<br/><br/>
> 🔐 Pessimistic delivers trusted security audits since 2017.
> 
> Require expert oversight for your project safety?
> 
> Explore our services at [pessimistic.io](https://pessimistic.io/).
