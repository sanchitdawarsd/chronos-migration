// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract chrDepositContract is Initializable, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    address public owner;
    IERC20 public chr;

    mapping(address => uint256) public userBalances; // Mapping from user address to balance
    mapping(address => bool) public deposited; // Mapping from user address to either deposited or not

    uint256 public deploymentTimestamp;
    uint256 public constant depositDuration = 30 days;

    event Deposit(address indexed user, uint256 amount);
    event UserMappingUpdated(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function initialize(address _chr) public initializer {
        __Ownable_init();
        chr = IERC20(_chr);
        deploymentTimestamp = block.timestamp;
    }

        // Function to input mapping from user address to balance
    function updateUserMapping(address userAddress,uint256 amount) external onlyOwner {

        // Update the mapping from NFT ID to user address
        userBalances[userAddress] = amount;
        
        // deposited as false on initializing
        deposited[userAddress] = false;

        // Emit an event or perform any other necessary actions
        emit UserMappingUpdated(userAddress, amount);
    }

// 10$ value above
    function deposit(uint256 amount) external nonReentrant {
        // Ensure the user can deposit after the lock duration has passed
        require(isWithinDepositPeriod(), "Deposit period has ended");
        require(userBalances[msg.sender] >= amount, "exceeeds the user balance during snapshot");

        // Transfer venft tokens from the user to this contract
        chr.transferFrom(msg.sender, address(this), amount);

        // update the user balance
        userBalances[msg.sender] = userBalances[msg.sender].sub(amount);

        //check deposited
        deposited[msg.sender] = true;

        // Emit deposit event
        emit Deposit(msg.sender, amount);
        

    }

     function isWithinDepositPeriod() public view returns (bool) {
        return block.timestamp <= deploymentTimestamp + depositDuration;
    }

    function withdraw(uint256 amount) external onlyOwner {
        // Owner can withdraw chr tokens from the contract
        chr.transfer(owner, tokenId);
    }
}
