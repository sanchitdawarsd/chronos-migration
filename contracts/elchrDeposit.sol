// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract elChrDepositContract is Ownable, ReentrancyGuard {
    using Math for uint256;
    
    IERC20 public elChrToken;

    mapping(address => uint256) public userBalances; // Mapping from user address to balance
    mapping(address => uint256) public depositedAmount; // Mapping to amount deposited

    uint256 public deploymentTimestamp;
    uint256 public constant depositDuration = 30 days;
    address[] public userList; // Array to store user addresses

    event Deposit(address indexed user, uint256 amount);
    event UserMappingUpdated(address indexed user, uint256 amount);

    constructor(address _elChrToken) Ownable(msg.sender) {
        elChrToken = IERC20(_elChrToken);
        deploymentTimestamp = block.timestamp;
    }

    // Function to input mapping from user address to balance
    function updateUserMapping(address[] memory userAddresses, uint256[] memory amounts) external onlyOwner {
        require(userAddresses.length == amounts.length, "Arrays length mismatch");

        for (uint256 i = 0; i < userAddresses.length; i++) {

        // Update the mapping from NFT ID to user address
        userBalances[userAddresses[i]] = amounts[i];

        // Emit an event or perform any other necessary actions
        emit UserMappingUpdated(userAddresses[i], amounts[i]);

        }
    }

        function deposit(uint256 amount) external nonReentrant {
        // Ensure the user can deposit after the lock duration has passed
        require(isWithinDepositPeriod(), "Deposit period has ended");

        // Transfer venft tokens from the user to this contract
        elChrToken.transferFrom(msg.sender, address(this), amount);

        //amount deposited
        depositedAmount[msg.sender] += amount;

        // push user to list
        userList.push(msg.sender);

        // Emit deposit event
        emit Deposit(msg.sender, amount);  

    }

     function isWithinDepositPeriod() public view returns (bool) {
        return block.timestamp <= deploymentTimestamp + depositDuration;
    }

    function withdraw(uint256 amount) external onlyOwner {
        // Owner can withdraw elChrToken tokens from the contract
        elChrToken.transfer(owner(), amount);
    }
}
