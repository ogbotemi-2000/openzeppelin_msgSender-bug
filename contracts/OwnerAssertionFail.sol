// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/utils/Context.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";
import "./Ownable.sol";

contract Invoke is Context {
    Token token;

    constructor(Token _token) {
        token = _token;
    }

    function show() public {
      token.logSender();
    }
}


contract Token is ERC20, Ownable {
    constructor() ERC20("Token", "TKN") { }

    function logSender() public virtual {
        /* smart contract have a non-zero value for the length of the code of their addresses */
        console.log("::Token::logSender::", _msgSender(), owner(), _msgSender().code.length);
        assert(owner()==_msgSender());
    }
}