// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract chrNftDeposit is Initializable,IERC721Receiver, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    // chr nft address
    IERC721Upgradeable public chrNft;
    
    // ERC-721 interface identifier
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Event to log the token transfer
    event ReceivedERC721(address operator, address from, uint256 tokenId, bytes data);

    mapping(address => uint256) public totalids; // Mapping from NFT ID to user address
    mapping(uint256 => mapping(address => bool)) public deposited; // Mapping from Venft ID to user address (since one address can have multiple venfts) to either deposited or not


    uint256 public deploymentTimestamp;
    uint256 public depositDuration = 30 days;

    event Deposit(address indexed user, uint256 tokenId);
    event UserMappingUpdated(address indexed user, uint256 tokenId);

    function initialize(address _chrNft) public initializer {
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        chrNft = IERC721Upgradeable(_chrNft);
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

      
    function deposit(uint256 tokenId) external nonReentrant {
        // Ensure the user can deposit after the lock duration has passed
        require(isWithinDepositPeriod(), "Deposit period has ended");
        require(deposited[tokenId][msg.sender] == false,"Already Deposited");

        // Transfer venft tokens from the user to this contract
        chrNft.safeTransferFrom(msg.sender, address(this), tokenId);

        //check deposited
        deposited[tokenId][msg.sender] = true;

        totalids[msg.sender]= totalids[msg.sender]+1;

        // Emit deposit event
        emit Deposit(msg.sender, tokenId);
        

    }

     function isWithinDepositPeriod() public view returns (bool) {
        return block.timestamp <= deploymentTimestamp + depositDuration;
    }
        // Function to update the deposit duration
    function updateDepositDuration(uint256 _newDuration) external onlyOwner {
        depositDuration = _newDuration;
    }

    function withdraw(uint256 tokenId) external onlyOwner {
        // Owner can withdraw venft tokens from the contract
        chrNft.safeTransferFrom(address(this), owner(), tokenId);
    }
}
