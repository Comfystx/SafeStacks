# SafeStacks 🔒

A secure multi-signature wallet implementation for teams and organizations on the Stacks blockchain.

## Overview

SafeStacks provides multi-signature wallet functionality that enables teams to manage shared funds with configurable approval thresholds. The contract ensures that no single party can unilaterally control funds, requiring multiple signatures for transaction execution.

## Features

- **Multi-Signature Authorization**: Configurable threshold voting system for fund release
- **Vault Management**: Create and manage multiple isolated vaults
- **Emergency Controls**: Lock/unlock functionality for security incidents
- **Transaction Proposals**: Propose, sign, and execute transactions with multi-party approval
- **STX Token Support**: Native support for STX token transfers
- **Security Validations**: Comprehensive input validation and error handling

## Key Components

### Vaults
- Support up to 10 signers per vault
- Configurable signature threshold (1 to number of signers)
- Individual balance tracking
- Active/inactive status management

### Transactions
- Proposal-based transaction system
- Signature collection and verification
- Threshold-based execution
- Prevention of double-spending and replay attacks

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

### Depositing Funds
```clarity
(contract-call? .safestacks deposit-to-vault u1 u1000000) ;; 1 STX
```

### Proposing a Transaction
```clarity
(contract-call? .safestacks propose-transaction 
  u1 ;; vault-id
  'SP... ;; recipient
  u500000) ;; amount (0.5 STX)
```

### Signing a Transaction
```clarity
(contract-call? .safestacks sign-transaction u1 u1) ;; vault-id, tx-id
```

### Executing a Transaction
```clarity
(contract-call? .safestacks execute-transaction u1 u1) ;; vault-id, tx-id
```

## Security Features

- **Input Validation**: All parameters are validated for correctness
- **Authorization Checks**: Only authorized signers can perform operations
- **Reentrancy Protection**: Safe transfer patterns prevent reentrancy attacks
- **Emergency Controls**: Emergency lock prevents all operations when activated
- **Signature Verification**: Prevents double-signing and unauthorized signatures

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

## Development

### Prerequisites
- Clarinet CLI
- Stacks blockchain development environment

### Running Tests
```bash
clarinet check
clarinet test
```

### Deployment
```bash
clarinet deploy
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests with `clarinet check`
5. Submit a pull request

