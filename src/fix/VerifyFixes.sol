// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./Context.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";
import "./Ownable.sol";

contract Invoke is Context {
    Token token;
    address receiver = address(10); 

    constructor(Token _token) {
        token = _token;
    }

    function show() public {
      token.logSender();
    }
    function transferTokens() public virtual {
      /*this code reverts  with an InsufficientBalance even when more than the sent ether has been minted to the owner() in Token.sol
        This is a huge problem that locks the owner out of his own minted balance
        when he wants to say, launch  a presale for his token since he can't do anything regarding transfer of tokens from his presale address
       */
      token.transfer(receiver, 50 ether);
      // Yet, his balance reflects his non-zero amount of tokens and further adds to his confusion and frustration
      console.log("::Presale::token::balanceOf", token.balanceOf(_msgSender()));
    }

    function mintTokens() public virtual  {
        /** reverts because owner() != _msgSender() since its value is immutably cached in the private variable _owner
         */
        token.mintToOwner(50 ether);
    }
}


contract Token is ERC20, Ownable {
    constructor() /*ERC20("Token", "TKN")*/ { 
       mintToOwner(100 ether);
    }

    function mintToOwner(uint256 amount) public onlyOwner {
      /* reverts due to the onlyOwner modifier which is dependent on the immutable return value of owner()
         This is because `owner` returns the value of the private variable
         _owner which is assigned the value of msg.sender once
      */
      _mint(owner(), amount);
    }
    
    function logSender() public virtual {
        /* smart contract have a non-zero value for the length of the code of their addresses */
        console.log("::Token::logSender::", _msgSender(), owner(), _msgSender().code.length);
        assert(owner()==_msgSender());
    }
}