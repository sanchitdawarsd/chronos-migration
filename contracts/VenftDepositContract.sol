// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract VenftDepositContract is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;

    address public owner;
    IERC721Upgradeable public venftToken;

    mapping(address => uint256) public userBalances; // Mapping from user address to balance
    mapping(uint256 => address) public nftIdToAddress; // Mapping from NFT ID to user address
    mapping(uint256 => mapping(address => bool)) public deposited; // Mapping from Venft ID to user address (since one address can have multiple venfts) to either deposited or not


    uint256 public deploymentTimestamp;
    uint256 public constant depositDuration = 30 days;

    event Deposit(address indexed user, uint256 tokenId);
    event UserMappingUpdated(address indexed user, uint256 tokenId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function initialize(address _venftToken) public initializer {
        __Ownable_init();
        venftToken = IERC721Upgradeable(_venftToken);
        deploymentTimestamp = block.timestamp;
    }

        // Function to input mapping from user address to balance and Venft ID
    function updateUserMapping(address userAddress,uint256 tokenId) external onlyOwner {

        // Update the mapping from NFT ID to user address
        nftIdToAddress[tokenId] = userAddress;
        
        // deposited as false on initializing
        deposited[tokenId][msg.sender] = false;

        // Emit an event or perform any other necessary actions
        emit UserMappingUpdated(userAddress, tokenId);
    }

// 10$ value above
    function deposit(uint256 tokenId) external nonReentrant {
        // Ensure the user can deposit after the lock duration has passed
        require(isWithinDepositPeriod(), "Deposit period has ended");

        if(nftIdToAddress[tokenId] == msg.sender){ // since in data i can see after 5 dec some nfts have been moved to other addresses so restricting nft to be deposited from specific addresses as they were with the users of 5 dec 
       
        // Transfer venft tokens from the user to this contract
        venftToken.safeTransferFrom(msg.sender, address(this), tokenId);

        //check if deposited
        deposited[tokenId][msg.sender] = true;

        // Emit deposit event
        emit Deposit(msg.sender, tokenId);
        }

    }

     function isWithinDepositPeriod() public view returns (bool) {
        return block.timestamp <= deploymentTimestamp + depositDuration;
    }

    function withdraw(uint256 tokenId) external onlyOwner {
        // Owner can withdraw venft tokens from the contract
        venftToken.safeTransfer(owner, tokenId);
    }
}
