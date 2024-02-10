## Contract Initialization: 

The contract uses the Initializable contract from OpenZeppelin for initialization. It sets up initial parameters such as the Venly NFT token contract address and deployment timestamp. The contract also inherits from OwnableUpgradeable and ReentrancyGuardUpgradeable.

## Event: 

The contract defines an event ReceivedERC721 to log token transfers.
UserMappingUpdated - adding user of snapshots.
AddedToBlacklist - when a user is added to blacklist.
Deposit -  this event is emitted when a user deposits a Venly NFT token into the contract with snapshot one.
Depositnsh -  this event is emitted when a user deposits a  veNFT token into the contract without snapshot one.

## Mappings:

userBalances: Maps user addresses to their balances.
nftIdToAddress: Maps NFT IDs to user addresses.
deposited: Maps Venft IDs to user addresses to track whether an NFT has been deposited or not.
blacklist: Maintains a list of blacklisted addresses.

## Functions:

initialize: Initializes the contract with the Venly NFT token contract address.

onERC721Received: Implements the onERC721Received function required by the ERC-721 standard. This function is called when an ERC-721 token is received.

updateUserMapping: Allows the contract owner to update the mapping from user addresses to balances and Venft IDs.

deposit: Allows users to deposit Venly NFT tokens into the contract within a specified duration. It checks various conditions such as whether the deposit period is ongoing, whether the user has already deposited the token, and whether the user is blacklisted.

depositnsh: Similar to deposit function but without the requirement of the user owning the NFT beforehand in snapshot.

isWithinDepositPeriod: Checks whether the current block timestamp is within the specified deposit duration.

withdraw: Allows the owner to withdraw Venly NFT tokens from the contract.
addToBlacklist: Allows the contract owner to add addresses to the blacklist, preventing them from depositing tokens.

## Modifiers:

onlyOwner: Restricts access to certain functions to only the contract owner.
nonReentrant: Prevents reentrancy attacks by restricting reentrant calls to functions guarded by this modifier.