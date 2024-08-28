// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

//import necessary smart contracts
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

//import our stablecoin smart contract
import "./UrbaneStablecoin.sol";

contract Governance is Ownable, ReentrancyGuard, AccessControl{
    using SafeERC20 for IERC20;

    //create a new governance role
    bytes32 public constant GOVERN_ROLE = keccak256("GOVERN_ROLE");

    //struct to monitor the supply change
    struct SupplyChange{
        string method; //"burn" or "mint"
        uint256 amount;
        uint256 timestamp;
        uint256 blocknum;
    }

    //using Tether as our stable collateral and Ethereum as our unstable collateral
    struct ReserveList{
        IERC20 colToken;
    }

    mapping(uint256 => ReserveList) public rsvList;

    //to keep track of all the changes we make to adjust the price
    mapping (uint256 => SupplyChange) public _supplyChanges;

    //getting the instance of the stablecoin and defining other constant
    UrbaneStablecoin private usc;
    AggregatorV3Interface private priceOracle;

    //the Urbane collateral reserve smart contract address
    address private reserveContract;
    address public dataFeed;
    uint256 public uscSupply;
    uint256 public supplyChangeCount;
    uint256 public stableColatPrice = 1e18; 
    uint256 public stableColatAmount;
    int256 private constant COL_PRICE_TO_WEI = 1e10;
    uint256 private constant WEI_VALUE = 1e18;
    uint256 public unstableColatAmount;
    int256 public unstableColPrice;
    uint256 public reserveCount;

    //event to repeg and withdraw the amount
    event RepegAction(uint256 time, uint256 amount);
    event Withdraw(uint256 time, uint256 amount);

    constructor(UrbaneStablecoin _usc, address initialOwner) Ownable(initialOwner){
        usc = _usc;
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(GOVERN_ROLE, _msgSender());
    }

    //set the data feed address
    function setDataFeedAddress(address _contract) external{
        require(hasRole(GOVERN_ROLE, _msgSender()), "Not allowed to access the vault.");
        dataFeed = _contract;
        priceOracle = AggregatorV3Interface(dataFeed);
    }

    //add a new collateral token
    function addCollateralToken(IERC20 _collateral) external nonReentrant{
        require(hasRole(GOVERN_ROLE, _msgSender()), "Not allowed to access the vault.");
        
        //similar to the reserve contract
        rsvList[reserveCount].colToken = _collateral;
        reserveCount++;
    }

    //fetch the the unstable collateral price
    function fetchColPrice() external nonReentrant{
        require(hasRole(GOVERN_ROLE, _msgSender()), "Not allowed to access the ETH/USD price data feed.");
        ( , int256 price, , , ) = priceOracle.latestRoundData();
        int256 value = price * COL_PRICE_TO_WEI;

        //set the latest price of ETH/USD
        unstableColPrice = value;
    }

    //set the reserve contract address
    function setReserveContract(address reserve) external nonReentrant {
        require(hasRole(GOVERN_ROLE, _msgSender()), "Not allowed to access the vault.");
        reserveContract = reserve;
    }

    //set the total supply of USC
    function setUSCSupply(uint256 _supply) external{
        uscSupply = _supply;
    }

    //withdraw the USC to another account
    function withdraw(uint256 _amount) external nonReentrant{
        require(hasRole(GOVERN_ROLE, _msgSender()), "Not allowed to withdraw Urbane Stablecoin.");
        usc.transfer(address(msg.sender), _amount);
        emit Withdraw(block.timestamp, _amount);
    }

    //balance the stable and unstable collateral prices
    function collateralRebalancing() internal returns(bool){
        require(hasRole(GOVERN_ROLE, _msgSender()), "Not allowed to access the vault.");

        //get the balances of the reserve contract
        uint256 stableBalance = rsvList[0].colToken.balanceOf(reserveContract);
        uint256 unstableBalance = rsvList[1].colToken.balanceOf(reserveContract);

        //update the balances of the stable and unstable collateral
        if(stableBalance != stableColatAmount){
            stableColatAmount = stableBalance;
        }

        if(unstableBalance != stableColatAmount){
            unstableColatAmount = unstableBalance;
        }

        return true;
    }

    //main algorithm to repeg the price of the stablecoin
    function validatePeg() external nonReentrant{
        require(hasRole(GOVERN_ROLE, _msgSender()), "Not allowed to access the vault.");
        
        //update the collateral prices
        bool result = collateralRebalancing();
        if(result == true){
            //calculate the total value of the collateral we have in our reserves after updating the prices
            uint256 rawColValue = stableColatAmount* WEI_VALUE + uint256(unstableColatAmount)*uint256(unstableColPrice);
            uint256 colValue = rawColValue/WEI_VALUE;
            uscSupply = usc.totalSupply();

            //if we have lesser collateral than required to back up our token supply so value of our token reduces so we burn the extra tokens -> supply reduces but the price ratio remains 1 : 1 so price remains $1
            if(colValue < uscSupply){
                uint256 change = uscSupply - colValue;
                usc.burn(change);
                _supplyChanges[supplyChangeCount].method = "Burn";
                _supplyChanges[supplyChangeCount].amount = change;
            }
            
            //we have more collateral so we can mint more tokens and make the ratio 1:1 and the price remains $1
            if(colValue > uscSupply){
                uint256 change = colValue - uscSupply;
                usc.mint(change);
                _supplyChanges[supplyChangeCount].method = "Mint";
                _supplyChanges[supplyChangeCount].amount = change;
            }

            //since we have adjusted
            uscSupply = colValue;
            _supplyChanges[supplyChangeCount].blocknum = block.number;
            _supplyChanges[supplyChangeCount].timestamp = block.timestamp;
            supplyChangeCount++;

            //emit the event with the new colValue -> which is also our $USC supply
            emit RepegAction(block.timestamp, colValue);
        }   
    }
}