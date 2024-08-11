// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "hardhat/console.sol";

contract Token is ERC20 {
    constructor() ERC20("Token", "TKN") {
        console.log("::SENDER::", _msgSender(), _msgSender().code.length);
    }

    function showMutation() public virtual {
        console.log("::MUTATION::", _msgSender(), _msgSender().code.length);
    }
}