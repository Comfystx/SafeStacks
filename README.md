# SafeStacks 🔒

A secure multi-signature wallet implementation for teams and organizations on the Stacks blockchain with comprehensive SIP-010 fungible token support.

## Overview

SafeStacks provides multi-signature wallet functionality that enables teams to manage shared funds with configurable approval thresholds. The contract ensures that no single party can unilaterally control funds, requiring multiple signatures for transaction execution. Now supports both native STX tokens and SIP-010 compliant fungible tokens.

## Features

- **Multi-Signature Authorization**: Configurable threshold voting system for fund release
- **Vault Management**: Create and manage multiple isolated vaults
- **SIP-010 Token Support**: Full support for SIP-010 fungible tokens alongside native STX
- **Separate Token Balances**: Independent balance tracking for STX and each SIP-010 token
- **Emergency Controls**: Lock/unlock functionality for security incidents
- **Transaction Proposals**: Propose, sign, and execute transactions with multi-party approval
- **Dual Token System**: Support for both STX and any SIP-010 compliant token
- **Security Validations**: Comprehensive input validation and error handling

## Key Components

### Vaults
- Support up to 10 signers per vault
- Configurable signature threshold (1 to number of signers)
- STX balance tracking
- Individual SIP-010 token balance tracking per vault
- Active/inactive status management

### Transactions
- Proposal-based transaction system for both STX and SIP-010 tokens
- Signature collection and verification
- Threshold-based execution
- Token-specific transaction handling
- Prevention of double-spending and replay attacks

### SIP-010 Token Integration
- Trait-based token contract integration
- Safe token transfer mechanisms
- Individual token balance management
- Support for any compliant SIP-010 token

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

### Signing a Transaction
```clarity
(contract-call? .safestacks sign-transaction u1 u1) ;; vault-id, tx-id
```

### Executing a Transaction
```clarity
(contract-call? .safestacks execute-transaction u1 u1) ;; vault-id, tx-id
```

### Checking Token Balance
```clarity
(contract-call? .safestacks get-vault-token-balance 
  u1 ;; vault-id
  .my-token-contract) ;; token contract principal
```

## Security Features

- **Input Validation**: All parameters are validated for correctness
- **Authorization Checks**: Only authorized signers can perform operations
- **Token Safety**: Safe SIP-010 token transfer patterns prevent reentrancy attacks
- **Separate Balance Tracking**: STX and token balances are tracked independently
- **Emergency Controls**: Emergency lock prevents all operations when activated
- **Signature Verification**: Prevents double-signing and unauthorized signatures
- **Trait Validation**: Ensures only valid SIP-010 tokens are accepted

## Token Standards

### SIP-010 Compatibility
The contract implements the SIP-010 fungible token trait:
- `transfer`: Execute token transfers
- `get-balance`: Query token balances
- `get-name`, `get-symbol`, `get-decimals`: Token metadata
- `get-total-supply`: Total token supply information
- `get-token-uri`: Token metadata URI

### Supported Operations
- Deposit any SIP-010 compliant token
- Create multi-sig transactions for token transfers
- Independent balance tracking per token per vault
- Secure token transfer execution

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

## API Reference

### Read-Only Functions
- `get-vault-info(vault-id)`: Get vault details
- `get-vault-token-balance(vault-id, token-contract)`: Get token balance for vault
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
- `propose-stx-transaction(vault-id, recipient, amount)`: Propose STX transfer
- `propose-token-transaction(vault-id, recipient, amount, token-contract)`: Propose token transfer
- `sign-transaction(vault-id, tx-id)`: Sign pending transaction
- `execute-transaction(vault-id, tx-id)`: Execute approved transaction
- `emergency-lock()`: Lock all operations (owner only)
- `emergency-unlock()`: Unlock operations (owner only)

## Development

### Prerequisites
- Clarinet CLI
- Stacks blockchain development environment
- SIP-010 compliant token contracts for testing

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

### Multi-Token Vault Setup
```clarity
;; 1. Create vault
(contract-call? .safestacks create-vault 
  (list 'SP1AAA... 'SP1BBB... 'SP1CCC...) u2)

;; 2. Deposit STX
(contract-call? .safestacks deposit-stx-to-vault u1 u5000000)

;; 3. Deposit tokens
(contract-call? .safestacks deposit-token-to-vault u1 u1000000 .usda-token)
(contract-call? .safestacks deposit-token-to-vault u1 u2000000 .wrapped-bitcoin)

;; 4. Propose token transfer
(contract-call? .safestacks propose-token-transaction 
  u1 'SP1RECIPIENT... u500000 .usda-token)

;; 5. Collect signatures and execute
(contract-call? .safestacks sign-transaction u1 u1)
;; ... additional signers
(contract-call? .safestacks execute-token-transaction u1 u1 .usda-token)
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests with `clarinet check`
5. Ensure SIP-010 token compatibility
6. Submit a pull request

## License

MIT License - see LICENSE file for details.