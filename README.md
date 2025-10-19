# SafeStacks 🔒

A secure multi-signature wallet implementation for teams and organizations on the Stacks blockchain with comprehensive SIP-010 fungible token and SIP-009 NFT support.

## Overview

SafeStacks provides multi-signature wallet functionality that enables teams to manage shared funds with configurable approval thresholds. The contract ensures that no single party can unilaterally control funds, requiring multiple signatures for transaction execution. Now supports native STX tokens, SIP-010 compliant fungible tokens, and SIP-009 NFTs for comprehensive digital asset management.

## Features

- **Multi-Signature Authorization**: Configurable threshold voting system for fund release
- **Vault Management**: Create and manage multiple isolated vaults
- **SIP-010 Token Support**: Full support for SIP-010 fungible tokens alongside native STX
- **SIP-009 NFT Support**: Multi-sig control for NFT collections and rare digital assets
- **NFT Vault Management**: Secure storage and transfer of valuable NFTs with multi-party approval
- **Separate Token Balances**: Independent balance tracking for STX and each SIP-010 token
- **NFT Holdings Tracking**: Track NFT ownership per vault and collection
- **Emergency Controls**: Lock/unlock functionality for security incidents
- **Transaction Proposals**: Propose, sign, and execute transactions with multi-party approval
- **Multi-Asset System**: Support for STX, any SIP-010 compliant token, and any SIP-009 NFT
- **Security Validations**: Comprehensive input validation and error handling

## Key Components

### Vaults
- Support up to 10 signers per vault
- Configurable signature threshold (1 to number of signers)
- STX balance tracking
- Individual SIP-010 token balance tracking per vault
- NFT holdings tracking per vault and collection
- Active/inactive status management

### Transactions
- Proposal-based transaction system for STX, SIP-010 tokens, and SIP-009 NFTs
- Signature collection and verification
- Threshold-based execution
- Asset-specific transaction handling
- Prevention of double-spending and replay attacks

### SIP-010 Token Integration
- Trait-based token contract integration
- Safe token transfer mechanisms
- Individual token balance management
- Support for any compliant SIP-010 token

### SIP-009 NFT Integration
- Trait-based NFT contract integration
- Secure NFT transfer mechanisms
- Per-NFT ownership tracking
- Support for any compliant SIP-009 NFT collection
- Multi-sig control for rare and valuable digital assets

### Emergency Features
- Contract-wide emergency lock mechanism
- Owner-controlled emergency unlock
- Protection against unauthorized access during incidents

## Usage

### Creating a Vault
```clarity
(contract-call? .safestacks create-vault 
  (list 'SP1... 'SP2... 'SP3...) ;; signers
  u2) ;; threshold (2 out of 3)
```

### Depositing STX
```clarity
(contract-call? .safestacks deposit-stx-to-vault u1 u1000000) ;; 1 STX to vault 1
```

### Depositing SIP-010 Tokens
```clarity
(contract-call? .safestacks deposit-token-to-vault 
  u1 ;; vault-id
  u1000000 ;; amount (1 token with 6 decimals)
  .my-token-contract) ;; SIP-010 token contract
```

### Depositing NFTs
```clarity
(contract-call? .safestacks deposit-nft-to-vault 
  u1 ;; vault-id
  .my-nft-collection ;; SIP-009 NFT contract
  u42) ;; token-id
```

### Proposing an STX Transaction
```clarity
(contract-call? .safestacks propose-stx-transaction 
  u1 ;; vault-id
  'SP... ;; recipient
  u500000) ;; amount (0.5 STX)
```

### Proposing a Token Transaction
```clarity
(contract-call? .safestacks propose-token-transaction 
  u1 ;; vault-id
  'SP... ;; recipient
  u500000 ;; amount
  .my-token-contract) ;; SIP-010 token contract
```

### Proposing an NFT Transaction
```clarity
(contract-call? .safestacks propose-nft-transaction 
  u1 ;; vault-id
  'SP... ;; recipient
  .my-nft-collection ;; SIP-009 NFT contract
  u42) ;; token-id
```

### Signing a Transaction
```clarity
(contract-call? .safestacks sign-transaction u1 u1) ;; vault-id, tx-id
```

### Executing an STX Transaction
```clarity
(contract-call? .safestacks execute-stx-transaction u1 u1) ;; vault-id, tx-id
```

### Executing a Token Transaction
```clarity
(contract-call? .safestacks execute-token-transaction 
  u1 ;; vault-id
  u1 ;; tx-id
  .my-token-contract) ;; token contract
```

### Executing an NFT Transaction
```clarity
(contract-call? .safestacks execute-nft-transaction 
  u1 ;; vault-id
  u1 ;; tx-id
  .my-nft-collection) ;; NFT contract
```

### Checking Token Balance
```clarity
(contract-call? .safestacks get-vault-token-balance 
  u1 ;; vault-id
  .my-token-contract) ;; token contract principal
```

### Checking NFT Ownership
```clarity
(contract-call? .safestacks get-vault-nft-owned 
  u1 ;; vault-id
  .my-nft-collection ;; NFT contract
  u42) ;; token-id
```

## Security Features

- **Input Validation**: All parameters are validated for correctness
- **Authorization Checks**: Only authorized signers can perform operations
- **Token Safety**: Safe SIP-010 token transfer patterns prevent reentrancy attacks
- **NFT Safety**: Secure SIP-009 NFT transfer patterns with ownership verification
- **Separate Balance Tracking**: STX, token, and NFT holdings are tracked independently
- **Emergency Controls**: Emergency lock prevents all operations when activated
- **Signature Verification**: Prevents double-signing and unauthorized signatures
- **Trait Validation**: Ensures only valid SIP-010 tokens and SIP-009 NFTs are accepted
- **Ownership Verification**: NFTs must be owned by vault before transfer proposals

## Asset Standards

### SIP-010 Compatibility
The contract implements the SIP-010 fungible token trait:
- `transfer`: Execute token transfers
- `get-balance`: Query token balances
- `get-name`, `get-symbol`, `get-decimals`: Token metadata
- `get-total-supply`: Total token supply information
- `get-token-uri`: Token metadata URI

### SIP-009 Compatibility
The contract implements the SIP-009 NFT trait:
- `transfer`: Execute NFT transfers
- `get-owner`: Query NFT ownership
- `get-last-token-id`: Query collection size
- `get-token-uri`: NFT metadata URI

### Supported Operations
- Deposit any SIP-010 compliant token
- Deposit any SIP-009 compliant NFT
- Create multi-sig transactions for token and NFT transfers
- Independent balance tracking per token per vault
- Independent NFT holdings tracking per collection per vault
- Secure token and NFT transfer execution

## Error Codes

- `u1001`: Not authorized
- `u1002`: Invalid threshold
- `u1003`: Insufficient signers
- `u1004`: Already signed
- `u1005`: Transaction not found
- `u1006`: Transaction already executed
- `u1007`: Insufficient votes
- `u1008`: Vault locked
- `u1009`: Invalid amount
- `u1010`: Invalid recipient
- `u1011`: Invalid token contract
- `u1012`: Token transfer failed
- `u1013`: Invalid NFT contract
- `u1014`: NFT transfer failed
- `u1015`: NFT not owned by vault

## API Reference

### Read-Only Functions
- `get-vault-info(vault-id)`: Get vault details
- `get-vault-token-balance(vault-id, token-contract)`: Get token balance for vault
- `get-vault-nft-owned(vault-id, nft-contract, token-id)`: Check NFT ownership
- `is-vault-signer(vault-id, signer)`: Check if address is vault signer
- `get-pending-transaction(vault-id, tx-id)`: Get transaction details
- `has-signed-transaction(vault-id, tx-id, signer)`: Check signature status
- `get-contract-owner()`: Get contract owner
- `is-emergency-locked()`: Check emergency lock status
- `get-next-transaction-id()`: Get next transaction ID

### Public Functions
- `create-vault(signers, threshold)`: Create new multi-sig vault
- `deposit-stx-to-vault(vault-id, amount)`: Deposit STX to vault
- `deposit-token-to-vault(vault-id, amount, token-contract)`: Deposit SIP-010 tokens
- `deposit-nft-to-vault(vault-id, nft-contract, token-id)`: Deposit SIP-009 NFT
- `propose-stx-transaction(vault-id, recipient, amount)`: Propose STX transfer
- `propose-token-transaction(vault-id, recipient, amount, token-contract)`: Propose token transfer
- `propose-nft-transaction(vault-id, recipient, nft-contract, token-id)`: Propose NFT transfer
- `sign-transaction(vault-id, tx-id)`: Sign pending transaction
- `execute-stx-transaction(vault-id, tx-id)`: Execute approved STX transaction
- `execute-token-transaction(vault-id, tx-id, token-contract)`: Execute approved token transaction
- `execute-nft-transaction(vault-id, tx-id, nft-contract)`: Execute approved NFT transaction
- `emergency-lock()`: Lock all operations (owner only)
- `emergency-unlock()`: Unlock operations (owner only)

## Development

### Prerequisites
- Clarinet CLI
- Stacks blockchain development environment
- SIP-010 compliant token contracts for testing
- SIP-009 compliant NFT contracts for testing

### Running Tests
```bash
clarinet check
clarinet test
```

### Deployment
```bash
clarinet deploy
```

## Examples

### Multi-Asset Vault Setup
```clarity
;; 1. Create vault
(contract-call? .safestacks create-vault 
  (list 'SP1AAA... 'SP1BBB... 'SP1CCC...) u2)

;; 2. Deposit STX
(contract-call? .safestacks deposit-stx-to-vault u1 u5000000)

;; 3. Deposit tokens
(contract-call? .safestacks deposit-token-to-vault u1 u1000000 .usda-token)
(contract-call? .safestacks deposit-token-to-vault u1 u2000000 .wrapped-bitcoin)

;; 4. Deposit NFTs
(contract-call? .safestacks deposit-nft-to-vault u1 .megapont-ape-club u1337)
(contract-call? .safestacks deposit-nft-to-vault u1 .stacks-punks u42)

;; 5. Propose NFT transfer
(contract-call? .safestacks propose-nft-transaction 
  u1 'SP1RECIPIENT... .megapont-ape-club u1337)

;; 6. Collect signatures and execute
(contract-call? .safestacks sign-transaction u1 u1)
;; ... additional signers
(contract-call? .safestacks execute-nft-transaction u1 u1 .megapont-ape-club)
```

### NFT Collection Management
```clarity
;; Secure a valuable NFT collection
(contract-call? .safestacks deposit-nft-to-vault u1 .rare-collection u1)
(contract-call? .safestacks deposit-nft-to-vault u1 .rare-collection u2)
(contract-call? .safestacks deposit-nft-to-vault u1 .rare-collection u3)

;; Propose transfer with multi-sig approval
(contract-call? .safestacks propose-nft-transaction 
  u1 'SP1BUYER... .rare-collection u1)

;; Requires threshold signatures before execution
(contract-call? .safestacks sign-transaction u1 u2)
(contract-call? .safestacks execute-nft-transaction u1 u2 .rare-collection)
```

## Use Cases

### NFT Treasury Management
- DAOs managing community-owned NFT collections
- Investment groups holding rare digital assets
- Teams managing project NFT reserves
- Collector syndicates requiring multi-party approval

### Token and Asset Diversification
- Multi-sig wallets holding STX, tokens, and NFTs
- Project treasuries with diverse digital assets
- Investment funds managing multiple asset types
- Organizations requiring approval for any asset transfer

### Security for High-Value Assets
- Protection of blue-chip NFT collections
- Multi-sig approval for rare asset transfers
- Team-controlled valuable digital art
- Institutional-grade NFT custody

