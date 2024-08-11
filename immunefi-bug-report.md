## Brief/Intro
A smart contract's owner's balance and allowance becomes zero, transfers are not possible due to insufficient balance errors, when its functions are invoked by another smart contract. The owner is unable to interact between his smart contracts say `Token` and `Presale`


## Vulnerability Details
The `transfer`, `transferForm` and `approve` functions in OpenZeppelin's ERC20.sol obtain the smart contract owner's address via the `_msgSender` function in utils/Context.sol.

The return value of `_msgSender` being dynamic, given that `return msg.sender` is the function's body, leaves room for changes in its value if the "sender" is another smart contract and not an address.

For a smart contract with address `0x540d7E428D5207B30EE03F2551Cbb5751D3c7569` that is owned by a user with public address `0x5B38Da6a701c568545dCfcB03FcB875f56beddC4`, _msgSender returns `0x540d7E428D5207B30EE03F2551Cbb5751D3c7569` instead of the expected `0x5B38Da6a701c568545dCfcB03FcB875f56beddC4` when the said smart contract invokes the functions in another.

This means that mappings that use the owner's address as a key to store some information will have the values for its keys reverted to their defaults - 0 for numbers, 0x0...000 for addresses etc, because of the different address returned by `_msgSender`.

These mappings - `_allowances` and `_balances` obtain the *expected-to-be-immutable* address of the owner via `_msgSender` and use it as a key to store the owner's balance through the same line of code in the **transfer**, **transferForm** and **approve** functions:
```sol
address owner = _msgSender();
```
Thereby affecting the three functions with this bug.


## Impact Details
#### 1. Contract fails to deliver promised returns, but doesn't loose value
From the comments describing `_msgSender` function in `Context.sol`, the devs justify its creation by stating that accessing `msg.sender` directly doesn't consider changes in its value when dealing with meta-transactions.
> The Context contract fails to deliver its promise when its invoked by a smart contract.

#### 2. Permanent freezing of funds
In the solidity file below, an owner seeking to _transfer_ funds to users during the presale of his `Token` is frustrated by the mutability of the return value of `_msgSender`, a development that locks him out of his minted balance when he launched `Token`.
This development lasts for as long as the `Presale`contract is active or indefinitely.

```sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/utils/Context.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "hardhat/console.sol";
import "./Ownable.sol";

contract Presale is Context {
    Token token;
    address receiver = address(10); 

    constructor(Token _token) {
        token = _token;
    }

    function transferTokens() public virtual {
      /*this code reverts  with an InsufficientBalance even when more than the sent ether has been minted to the owner() in Token.sol
        This is a huge problem that locks the owner out of his own minted balance
        when he wants to say, launch  a presale for his token since he can't do anything regarding transfer of tokens from his presale address
       */
      token.transfer(receiver, 50 ether);
      /** Yet, his balance reflects his non-zero amount of tokens and further adds to the
          confusion and frustration
      */
      console.log("::Presale::token::balanceOf", token.balanceOf(_msgSender()));
    }

    function mintTokens() public virtual  {
        /** reverts because owner() != _msgSender() since its value is immutably cached in the private variable _owner
         */
        token.mintToOwner(50 ether);
    }
}


contract Token is ERC20, Ownable {
    constructor() ERC20("Token", "TKN") {
        /*mint some token to the owner only to transfer some out of it to an address in Invoke.sol*/
        mintToOwner(100 ether);
    }

    function mintToOwner(uint256 amount) public onlyOwner {
      /* reverts due to the onlyOwner modifier which is dependent on the immutable return value of owner()
         This is because `owner` returns the value of the private variable
         _owner which is assigned the value of msg.sender once
      */
      _mint(owner(), amount);
    }
    
}
```

#### 3. Permanent denial of service
In similar fashion to the point above, the owner is denied the services supplied by the functions `transfer`, `transferFrom` and `approve` because they will always fail because of `revert InsufficientBalance(...)`.
This is because `_allowances` and `_balances` will then store a value of `0` for the new key that is the `Presale` smart contract address returned by `_msgSender`. 

## References
Add any relevant links to documentation or code
Here is a github repo I created yesterday to further document this discovery as a well as an clear, effective, concise and mainnet ready solution to this bug: https://github.com/ogbotemi-2000/openzeppelin_msgSender-bug 