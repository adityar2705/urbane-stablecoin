// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

//Urbane collateral reserves smart contract
contract UrbaneReserve is Ownable, ReentrancyGuard, AccessControl{
    using SafeERC20 for uint256;

    //ID of the latest reserve vault added
    uint256 public currentReserveId;

    //reserve vault struct
    struct ReserveVault{
        IERC20 collateral;
        uint256 amount;
    }

    //reserve vault mapping
    mapping(uint256 => ReserveVault) public _rsvVault;

    //withdraw and deposit events : vid -> vault ID
    event Withdraw(uint256 indexed vid, uint256 amount);
    event Deposit(uint256 indexed vid, uint256 amount);

    //defining the admin role
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    //defining the constructor and admin and manager roles
    constructor(address initialOwner) Ownable(initialOwner){
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(MANAGER_ROLE, _msgSender());
    }

    //check the reserve contract to see if collateral is already added
    function checkReserveContract(IERC20 _collateral) internal view{
        for(uint256 i = 0; i<currentReserveId; i++){
            require(_rsvVault[i].collateral != _collateral, "Collateral address already exists.");
        }
    }

    //add a new reserve vault with new collateral and amount
    function addReserveVault(IERC20 _collateral) external{
        require(hasRole(MANAGER_ROLE, _msgSender()), "Not allowed to access the vault.");
        checkReserveContract(_collateral);
        _rsvVault[currentReserveId].collateral = _collateral;
        currentReserveId++;
    }

    //deposit the collateral into the reserve vault
    function depositCollateral(uint256 vid, uint256 amount) external{
        require(hasRole(MANAGER_ROLE, _msgSender()), "Not allowed to access the vault.");
        IERC20 reserves = _rsvVault[vid].collateral;

        //transfer some amount of the collateral to the smart contract
        reserves.transferFrom(address(msg.sender), address(this), amount);
        uint256 currBalance = _rsvVault[vid].amount;
        _rsvVault[vid].amount = currBalance + amount;
        emit Deposit(vid, amount);
    }

    //Withdraw the collateral from the reserve vault
    function withdrawCollateral(uint256 vid, uint256 amount) external{
        require(hasRole(MANAGER_ROLE, _msgSender()), "Not allowed to access the vault.");
        IERC20 reserves = _rsvVault[vid].collateral;
        uint256 currBalance = _rsvVault[vid].amount;

        //check if we have enough collateral to withdraw
        if(currBalance >= amount){
            reserves.transfer(address(msg.sender), amount);
            _rsvVault[vid].amount = currBalance - amount;
            emit Withdraw(vid, amount);
        }
    }
}
