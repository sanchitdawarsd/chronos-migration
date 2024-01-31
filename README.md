# Chronos Migration

## VECHR Migratration Info
Contract Imports:

The contract imports interfaces and libraries from OpenZeppelin for ERC721, Ownable, SafeMath, Initializable, and ReentrancyGuard functionalities.

### Contract State Variables:

owner: An address variable representing the owner of the contract.
venftToken: An ERC721 contract interface representing the Venft token.
userBalances: A mapping from user addresses to their balances.
nftIdToAddress: A mapping from NFT IDs to user addresses.
deposited: A mapping from Venft ID to user address to track whether an NFT has been deposited.
deploymentTimestamp: Records the timestamp of contract deployment.
depositDuration: A constant representing the duration during which deposits are allowed.

### Events:

Deposit: Triggered when a user deposits an NFT.
UserMappingUpdated: Triggered when the user-to-NFT mapping is updated.

### Modifiers:

onlyOwner: Ensures that only the owner can execute certain functions.

### Initializer Function:

The initialize function initializes the contract with the Venft token address and sets the deployment timestamp.

### Function updateUserMapping:

Only callable by the owner.
Updates the mapping from NFT ID to user address.
Sets the deposited status to false.
Emits an event to notify the mapping update.

### Function deposit:

Only callable within the deposit period.
Checks if the sender is the owner of the NFT.
Transfers the NFT to the contract.
Marks the NFT as deposited for the user.
Emits a deposit event.

### Function isWithinDepositPeriod:

Checks if the current timestamp is within the deposit period.

### Function withdraw:

Only callable by the owner.
Allows the owner to withdraw Venft tokens.