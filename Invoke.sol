// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "@openzeppelin/contracts/utils/Context.sol";
import "hardhat/console.sol";
import "./Token.sol";

contract Invoke is Context {
    Token token;

    constructor(Token _token) {
        token = _token;
        console.log("::Invoke::", address(token), _msgSender());
    }

    function show() public {
      token.showMutation();
    }
}