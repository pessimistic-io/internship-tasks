Решения нужно оформить в gist и скинуть ссылки на задачи **по отдельности**!

## Vesting
Нужно разобраться в коде. Написать небольшое описание того, как работает код.
Также нужно выписать уязвимости, пофиксить их в коде и отправить исправленную версию кода.

## Vulnerable BEP20
Нужно сравнить реализацию **BEP20** токена со [стандартом](https://github.com/bnb-chain/BEPs/blob/master/BEPs/BEP20.md) и выписать отличия.

Пример: Если реализация approve не соответствует формальным требованиям стандарта, выписать это несоответствие как ошибку. 
Если соответствует, выписывать ничего не надо.

## Libraries
Данные контракты образуют сложную цепочку вызовов. Нужно разобраться в коде. И ответить на вопросы:
1. Как инициализируется `_placementRegistry` из контракта **ManagerStorage**? (Напишите мини-контракт, в котором будет происходить инициализация).
2. Корректно ли добавляются items на строчке 73 в контракте **Placements**? Почему? (Дайте развернутое объяснение)
3. Для чего в **Items** используется `using Items for ItemtId`? (Дайте развернутое объяснение и укажите строчку в коде).
4. Как снимается комиссия за размещение? От кого и кому платится?  (Дайте развернутое объяснение)

## Airdrop
Нужно разобраться в коде, выписать ошибки и прислать контракт с фиксами.

## NFT
Нужно разобраться, как запустить [slither](https://github.com/crytic/slither) на данном контракте, и провалидировать вхождения всех уровней критичности, кроме `informational`. Все те, которые подтвердите, выписать.

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
