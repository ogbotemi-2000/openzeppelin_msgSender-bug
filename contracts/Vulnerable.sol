// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

import "hardhat/console.sol";

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}


abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
      /*this code reverts with an InsufficientBalance error because `transfer` obtains the address of the owner
	via _msgSender which naively returns an uncached `msg.sender` which resolves to the address of this smart contract with a default value of
	0 in the _balances mapping in the ERC20 contract.
	A fix is to make `_msgSender` return the original address that deployed this smart contract and the fix is present the Context contract in Fixed.sol
       */

      token.transfer(receiver, 50 ether);
      /* This code will be unreachable due to the reverted error above.

	`_msgSender` in this scope returns the address of who deployed the code thus, the balance is correctly logged as 100 ether as minted in the Token contract,
	this further adds to the confusion and frustration of the deployer who may be at a loss as to how his non-zero balance logged below can cause an
	InsufficentBalance error above. This scenario is particularly likely to happen in the event of a token presale
	*/
      console.log("::Presale::token::balanceOf", token.balanceOf(_msgSender()));
    }

    function mintTokens() public virtual  {
     /**since owner() != _msgSender(), the onlyOwner modifier applied to `mintToOwner` in Token makes the transaction revert
     */
        token.mintToOwner(50 ether);
    }
}


contract Token is ERC20, Ownable(msg.sender) {
    constructor() ERC20("Token", "TKN") {
      /*mint some token to the owner only to transfer some out of it to an address in the `Invoke` contract*/
      mintToOwner(100 ether);
    }

    function mintToOwner(uint256 amount) public onlyOwner {
      /*will revert when it is called in `Invoke` since the condition for the `onlyOwner` modifier - owner() == _msgSender(), is not met
      */
      _mint(owner(), amount);
    }
    
    function logSender() public virtual {
	/* smart contract addresses have a non-zero code.length as will be logged below to further show
	that msg.sender equals the address of the Invoke contract
	*/
        console.log("::Token::logSender::", _msgSender(), owner(), _msgSender().code.length);
	/* will fail because owner() returns the immutable private variable `_owner` in Ownable. This variable keeps the 
	correct value of the address that deployed this smart contract because it is only assigned to msg.sender in its constructor once.
	Whereas, `_msgSender` simply returns `msg.sender` every time.
	*/
        assert(owner()==_msgSender());
    }
}
