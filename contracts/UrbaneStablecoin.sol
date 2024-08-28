// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract UrbaneStablecoin is ERC20, ERC20Burnable, Ownable, AccessControl{
    using SafeERC20 for ERC20;
    
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    //initializing the Urbane stablecoin and granting the roles
    constructor(address initialOwner) ERC20("UrbaneStablecoin","URB") Ownable(initialOwner){
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(MANAGER_ROLE, _msgSender());
    }

    //keeping track of the user stablecoin balances
    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    //function to mint our stablecoin
    function mint(uint256 amount) external{
        require(hasRole(MANAGER_ROLE, _msgSender()), "Not allowed to mint the Urbane stablecoin.");
        _totalSupply += amount;
        _balances[msg.sender] += amount;

        //mint tokens to the caller of the function
        _mint(msg.sender, amount);
    }
}