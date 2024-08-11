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
      /*this code works with no errors - _msgSender in ERC20.sol now equals owner()
       */
      token.transfer(receiver, 50 ether);
      //The code below works fine just as it did in the buggy demonstrations at the root of contracts/
      console.log("::Presale::token::balanceOf", token.balanceOf(_msgSender()));
    }

    function mintTokens() public virtual  {
        /** since owner() == _msgSender(), the onlyOwner modifier
        does not affect the invocation of `mintToOwner` below
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
      /* does not revert since owner() now equals _msgSender() anyday, anytime
      by virtue of the workaround for _msgSender in ./Context.sol
      */
      _mint(owner(), amount);
    }
    
    function logSender() public virtual {
        /* wallet addresses have a code.length of zero whil smart contract address do not */
        console.log("::Token::logSender::", _msgSender(), owner(), _msgSender().code.length);
        assert(owner()==_msgSender());
    }
}