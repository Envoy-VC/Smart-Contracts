# Ether Wallet

Ethereum wallets are applications that let you interact with your Ethereum account. Think of it like an internet banking app – without the bank. Your wallet lets you read your balance, send transactions and connect to applications.

---

The owner's address is listed first in the contract.

```solidity
address payable public owner;
```

The address has the designation `payable` so that ether can be sent to it.

The owner variable in the constructor is set to `msg.sender`, or the deployer of the contract, upon initialization.

```solidity
constructor() {
    owner = payable(msg.sender);
}
```

We now have two unique functions called "receive" and "fallback" that allow the contract to accept plain ether with or without a calldata. For more information on these functions, [read on](https://dev.to/envoy_/day-25-fallback-and-receive-functions-4am0).

```solidity
receive() external payable {}
fallback() external payable {}
```

Following this, we require a function to withdraw our ether to the address of the owner; the `withdraw` function aids us in doing this. It has a `require` statement that makes that the owner, whom we initialised in the constructor, is the one calling the method. We transfer ether from the smart contract to the `msg.sender` if that criterion is satisfied.

```solidity
function withdraw(uint _amount) external {
    require(msg.sender == owner, "caller is not owner");
    payable(msg.sender).transfer(_amount);
}
```

Finally, we create a new function named `getBalance`, which is a view function, meaning that anyone can call it to retrieve the smart contract's balance without affecting the blockchain's current state.

```solidity
function getBalance() external view returns (uint) {
    return address(this).balance;
}
```

---
