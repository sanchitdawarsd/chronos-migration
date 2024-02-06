// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract chrTokenDepositContract is Ownable, ReentrancyGuard {
    using Math for uint256;
    
    IERC20 public chrToken;

    mapping(address => uint256) public userBalances; // Mapping from user address to balance
    mapping(address => uint256) public depositedAmount; // Mapping to amount deposited
    mapping(address => uint256) public depositedAmountnsh; // Mapping to amount deposited by nsh

    uint256 public deploymentTimestamp;
    uint256 public constant depositDuration = 30 days;
    address[] public userList; // Array to store user addresses

    event Deposit(address indexed user, uint256 amount);
    event Depositnsh(address indexed user, uint256 amount);
    event UserMappingUpdated(address indexed user, uint256 amount);

    constructor(address _chrToken) Ownable(msg.sender) {
        chrToken = IERC20(_chrToken);
        deploymentTimestamp = block.timestamp;
    }

        // Function to input mapping from user address to balance
    function updateUserMapping(address userAddress,uint256 amount) external onlyOwner {

        // Update the mapping from NFT ID to user address
        userBalances[userAddress] = amount;

        // Emit an event or perform any other necessary actions
        emit UserMappingUpdated(userAddress, amount);
    }

// 10$ value above
    function deposit(uint256 amount) external nonReentrant {
        // Ensure the user can deposit after the lock duration has passed
        require(isWithinDepositPeriod(), "Deposit period has ended");
        require(userBalances[msg.sender] >= amount, "exceeeds the user balance during snapshot");

        // Transfer venft tokens from the user to this contract
        chrToken.transferFrom(msg.sender, address(this), amount);

        //amount deposited
        depositedAmount[msg.sender] += amount;

        // push user to list
        userList.push(msg.sender);

        // update the user balance
        userBalances[msg.sender] -= amount;

        // Emit deposit event
        emit Deposit(msg.sender, amount);  

    }

        function depositnsh(uint256 amount) external nonReentrant {
        // Ensure the user can deposit after the lock duration has passed
        require(isWithinDepositPeriod(), "Deposit period has ended");

        // Transfer venft tokens from the user to this contract
        chrToken.transferFrom(msg.sender, address(this), amount);

        //amount deposited
        depositedAmountnsh[msg.sender] += amount;

        // push user to list
        userList.push(msg.sender);

        // Emit deposit event
        emit Depositnsh(msg.sender, amount);  

    }

     function isWithinDepositPeriod() public view returns (bool) {
        return block.timestamp <= deploymentTimestamp + depositDuration;
    }

    function withdraw(uint256 amount) external onlyOwner {
        // Owner can withdraw chrToken tokens from the contract
        chrToken.transfer(owner(), amount);
    }
}
