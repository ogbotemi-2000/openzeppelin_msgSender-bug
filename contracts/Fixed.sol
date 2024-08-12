// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

import "hardhat/console.sol";

/* The singular difference between this smart contract and its vulnerable counterpart is the 
addition of a private variable - _sender and a function _msgRoot in the Context contract
*/

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

abstract contract Context {

    address private msgRoot = msg.sender;
    function _msgRoot() internal view virtual returns (address) {
        return msgRoot;
    }
    /*end of custom code to ensure the immutability of the address returned by _msgSender
    */

    function _msgSender() internal view virtual returns (address) {
        return msgRoot;/*msg.sender*/
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


abstract contract ERC20 is IERC20, Context {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert("Blooper! Source address can't be 0x0000...");
        }
        if (to == address(0)) {
            revert("Blooper! Dest. address can't be 0x0000...");
        }
        _update(from, to, value);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply = _totalSupply + value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert("Address does not have enough balance");
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply = _totalSupply - value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] = _balances[to] + value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert("Blooper! Receiving address can't be 0x0000...");
        }
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert("Blooper! Address for this operation can't be 0x0000...");
        }
        _update(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert("Blooper! Address granting approval can't be 0x0000...");
        }
        if (spender == address(0)) {
            revert("Blooper! Permitted address can't be 0x0000...");
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert("Blooper! Insufficnent balance in address to be spent for transer ");
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}


abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);

    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


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
      /*this code works with no errors - _msgSender in ERC20.sol now equals owner() thereby
	making owner = _msgSender() in `transfer` from the `ERC20` contract above equal owner()
       */
      token.transfer(receiver, 50 ether);
      // The code below works fine just as it did in ./Vulnerable.sol - logs the balance of the wallet address of the smart contract owner
      console.log("::Presale::token::balanceOf", token.balanceOf(_msgSender()));
    }

    function mintTokens() public virtual  {
        /** since owner() == _msgSender(), the onlyOwner modifier
        does not affect the invocation of `mintToOwner` below when it is called from any other smart contract
	deployed by the same owner such as `Invoke` above 
         */
        token.mintToOwner(50 ether);
    }
}


contract Token is ERC20, Ownable(msg.sender) {
    constructor() ERC20("Token", "TKN") {
      /*mint some token to the owner only to transfer some out of it to an address in the `Invoke` contract */
      mintToOwner(100 ether);
    }

    function mintToOwner(uint256 amount) public onlyOwner {
      /* does not revert since owner() now equals _msgSender() anyday, anytime
      by virtue of the workaround for _msgSender in the `Context` contract
      */
      _mint(owner(), amount);
    }
    
    function logSender() public virtual {
        /* wallet addresses have a code.length of zero whil smart contract address do not */
        console.log("::Token::logSender::", _msgSender(), owner(), _msgSender().code.length);
        assert(owner()==_msgSender());
    }
}
