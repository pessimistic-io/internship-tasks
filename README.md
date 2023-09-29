This set of tasks is part of the Pessimistic Junior Solidity smart contracts security educational initiative. Learn more here: **% Link to the Post %**

Solutions need to be posted to [gist](https://gist.github.com/) and sent to us as **individuall** links for each task!

The Russian verison of the description see [below](#Vesting1).

## Vesting
Write a small description of how the code works.
You also need to write out the vulnerabilities, fix them in the code and send a corrected version of the code.

Note: you don't need to rewrite the whole code, it should be small edits.

## Vulnerable BEP20
We need to compare the implementation of **BEP20** token with [standard](https://github.com/bnb-chain/BEPs/blob/master/BEPs/BEP20.md) and write out the differences.

Example: If the implementation of the `approve` function does not meet the formal requirements of the standard, write this inconsistency as an issue. 
If it complies, write nothing.

## Libraries
Imagine that each contract is deployed separately. You need to understand the code and answer the questions:
1. How is the `_placementRegistry` from the **ManagerStorage** contract initialized? (Write a mini-contract with 3 variants of initialization. For instance, you can design it as 3 functions).
2. Are the items at line 73 in the **Placements** contract added correctly? Why? (Give a detailed explanation).
3. What is the purpose of `using Items for ItemtId` in **Items** library? (Give an extended explanation and specify the line in the code).
4. How is the placement fee deducted? Who is it paid from and to whom? How are `msg.sender` and `address(this)` changed with each external call?  (Give a detailed explanation)

## Airdrop
You need to understand the code, write out issues and send a contract with fixes.

Note: you don't need to rewrite the whole code, it should be small edits.

## NFT
You need to figure out how to run [slither](https://github.com/crytic/slither) on this contract, and check the occurrences of all severity levels except `informational`. Write out all the ones you confirm(with your brief description/comment).

Important: occurrences for **OpenZeppelin** contracts do not need to be validated!

The following command can be used to run [slither](https://github.com/crytic/slither) (do not exclude **OpenZeppelin** contracts via flags, as some occurrences may not display):
```
slither . --solc-disable-warnings --exclude-informational
```

## Foundry task

You are given a `foundry` project. Your task is to install it, run tests on fork **arbitrum** and explain why exactly they fail.

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
1. Where in the code is the `onERC721Received` function from Vault called? You need to write out the call chain
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

_________________

Решения нужно оформить в [gist](https://gist.github.com/) и скинуть ссылки на задачи **по отдельности**!

## Vesting
Нужно разобраться в коде. Написать небольшое описание того, как работает код.
Также нужно выписать уязвимости, пофиксить их в коде и отправить исправленную версию кода.

Примечание: не нужно переписывать весь код, это должны быть небольшие правки.

## Vulnerable BEP20
Нужно сравнить реализацию **BEP20** токена со [стандартом](https://github.com/bnb-chain/BEPs/blob/master/BEPs/BEP20.md) и выписать отличия.

Пример: Если реализация approve не соответствует формальным требованиям стандарта, выписать это несоответствие как ошибку. 
Если соответствует, выписывать ничего не надо.

## Libraries
Данные контракты образуют сложную цепочку вызовов. Представьте, что каждый контракт задеплоен отдельно. Нужно разобраться в коде. И ответить на вопросы:
1. Как инициализируется `_placementRegistry` из контракта **ManagerStorage**? (Напишите мини-контракт, в котором будут 3 варианта инициализации, можно оформить в виде 3 функций, например).
2. Корректно ли добавляются items на строчке 73 в контракте **Placements**? Почему? (Дайте развернутое объяснение)
3. Для чего в **Items** используется `using Items for ItemtId`? (Дайте развернутое объяснение и укажите строчку в коде).
4. Как снимается комиссия за размещение? От кого и кому платится? Как меняются `msg.sender` и `address(this)` с каждым внешним вызовом?  (Дайте развернутое объяснение)

## Airdrop
Нужно разобраться в коде, выписать ошибки и прислать контракт с фиксами.

Примечание: не нужно переписывать весь код, это должны быть небольшие правки.

## NFT
Нужно разобраться, как запустить [slither](https://github.com/crytic/slither) на данном контракте, и провалидировать вхождения всех уровней критичности, кроме `informational`. Все те, которые подтвердите, выписать(с Вашим кратким описанием/комментарием).

Важно: вхождения для контрактов **OpenZeppelin** валидировать не нужно!


Для запуска [slither](https://github.com/crytic/slither) можно использовать следующую команду (не исключайте контракты **OpenZeppelin** через флаги, так как некоторые вхождения могут не отобразиться):
```
slither . --solc-disable-warnings --exclude-informational
```


## Foundry task

Вам дан `foundry` проект. Ваша задача установить его, запустить тесты на форке **arbitrum** и объяснить, почему именно они не проходят.

В решении, пожалуйста, пришлите следующее:

1. Результаты запущенного теста.
2. Почему не проходит тест (используйте флаг `-vv` чтобы получить подробный результат). Опишите причину подробно.
3. Найдите конкретную строчку в коде, где происходят вычисления, которые не ожидались при написании теста.

#### Советы и ссылки

- документация [foundry](https://book.getfoundry.sh/)

- тесты рекомендуется запускать следующей командой:

```solidity
forge test -vv --fork-url <your-arbitrum-rpc-url>
```

- бесплатный rpc для арбитрума можно достать [тут](https://www.ankr.com/)

## Delegate Call
Данные контракты образуют сложную цепочку вызовов. Нужно разобраться в коде. И ответить на вопросы:

0. Какой контракт является точкой входа?
1. Где в коде вызывается функция `onERC721Received` из Vault? Нужно выписать цепочку вызовов
2. Чему равны `address(this)` и `msg.sender` при вызове `Controller.transferAssetToVault`?
3. Вернет ли `require` `revert` в `modifier whenAssetDepositAllowed` (контракт **Vault** ) или нет? Почему?
4. Правильно ли отработает `modifier onlyDelegatecall` из контракта **Controller**? Почему?
5. Cколько контрактов деплоится? Какие?

## King of the Ether

Есть игра King of the Ether:
- Контракт инициализируется с `1 ether` на балансе;
- Задача игры - застейкать эфира больше, чем остальные пользователи.
- Каждый человек имеет право докинуть эфира на контракт.
- Спустя 30 дней после создания контракта игра считается завершённой. И тот, кто больше всех застейкал эфира, получает в награду ещё один эфир.
- Человек не имеет права вывести эфир пока игра не закончилась.
- Когда игра закончилась, каждый человек может вызвать функцию withdraw чтобы забрать свой эфир.

Нужно написать контракт для этой игры, уязвимый к reentrancy, а так же написать атакующий контракт.

## Vulnerable ERC20

Нужно сравнить реализацию **ERC20** токена со [стандартом](https://eips.ethereum.org/EIPS/eip-20) и выписать отличия.

Пример: Если реализация approve не соответствует формальным требованиям стандарта, выписать это несоответствие как ошибку. 
Если соответствует, выписывать ничего не надо.