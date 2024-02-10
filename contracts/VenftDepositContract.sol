// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract VenftDepositContract is Initializable,IERC721Receiver, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    IERC721Upgradeable public venftToken;

    // ERC-721 interface identifier
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Event to log the token transfer
    event ReceivedERC721(address operator, address from, uint256 tokenId, bytes data);

    mapping(address => uint256) public userBalances; // Mapping from user address to balance
    mapping(uint256 => address) public nftIdToAddress; // Mapping from NFT ID to user address
    mapping(uint256 => mapping(address => bool)) public deposited; // Mapping from Venft ID to user address (since one address can have multiple venfts) to either deposited or not
    mapping(address => bool) public blacklist; // Mapping of blacklisted addresses

    uint256 public deploymentTimestamp;
    uint256 public constant depositDuration = 30 days;

    event Deposit(address indexed user, uint256 tokenId);
    event UserMappingUpdated(address indexed user, uint256 tokenId);
    event AddedToBlacklist(address indexed user);
    event Depositnsh(address indexed user, uint256 tokenId);

    function initialize(address _venftToken) public initializer {
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        venftToken = IERC721Upgradeable(_venftToken);
        deploymentTimestamp = block.timestamp;
    }

    // Implement the onERC721Received function
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        // You can add your custom logic here to handle the ERC-721 token transfer
        // For example, you might want to mint a new token, update some state, or perform other actions.

        // Emit an event to log the token transfer
        emit ReceivedERC721(operator, from, tokenId, data);

        // Return the ERC-721 interface identifier
        return _ERC721_RECEIVED;

    }    

    // Function to input mapping from user address to balance and Venft ID
    function updateUserMapping(address userAddress,uint256 tokenId) external onlyOwner {

        // Update the mapping from NFT ID to user address
        nftIdToAddress[tokenId] = userAddress;
        
        // deposited as false on initializing
        deposited[tokenId][userAddress] = false;

        // Emit an event or perform any other necessary actions
        emit UserMappingUpdated(userAddress, tokenId);
    }

// 10$ value above
    function deposit(uint256 tokenId) external nonReentrant {
        // Ensure the user can deposit after the lock duration has passed
        require(isWithinDepositPeriod(), "Deposit period has ended");
        require(deposited[tokenId][msg.sender] == false,"Already Deposited");
        require(nftIdToAddress[tokenId] == msg.sender, "user not exist in snapshot");
        require(!blacklist[msg.sender], "User is blacklisted");

        // Transfer venft tokens from the user to this contract
        venftToken.safeTransferFrom(msg.sender, address(this), tokenId);

        //check deposited
        deposited[tokenId][msg.sender] = true;

        // Emit deposit event
        emit Deposit(msg.sender, tokenId);

    }

        function depositnsh(uint256 tokenId) external nonReentrant {
        // Ensure the user can deposit after the lock duration has passed
        require(isWithinDepositPeriod(), "Deposit period has ended");
        require(deposited[tokenId][msg.sender] == false,"Already Deposited");
        require(!blacklist[msg.sender], "User is blacklisted");

        // Transfer venft tokens from the user to this contract
        venftToken.safeTransferFrom(msg.sender, address(this), tokenId);

        //check deposited
        deposited[tokenId][msg.sender] = true;

        // Emit deposit event
        emit Depositnsh(msg.sender, tokenId);

    }

     function isWithinDepositPeriod() public view returns (bool) {
        return block.timestamp <= deploymentTimestamp + depositDuration;
    }

    function withdraw(uint256 tokenId) external onlyOwner {
        // Owner can withdraw venft tokens from the contract
        venftToken.safeTransferFrom(address(this), owner(), tokenId);
    }
    
    // Function to add an address to the blacklist
    function addToBlacklist(address userAddress) external onlyOwner {
        blacklist[userAddress] = true;
        emit AddedToBlacklist(userAddress);
    }
}
