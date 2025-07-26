;; SafeStacks Multi-Sig Vault Contract
;; A secure multi-signature wallet implementation for teams and organizations

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u1001))
(define-constant ERR-INVALID-THRESHOLD (err u1002))
(define-constant ERR-INSUFFICIENT-SIGNERS (err u1003))
(define-constant ERR-ALREADY-SIGNED (err u1004))
(define-constant ERR-TRANSACTION-NOT-FOUND (err u1005))
(define-constant ERR-TRANSACTION-ALREADY-EXECUTED (err u1006))
(define-constant ERR-INSUFFICIENT-VOTES (err u1007))
(define-constant ERR-VAULT-LOCKED (err u1008))
(define-constant ERR-INVALID-AMOUNT (err u1009))
(define-constant ERR-INVALID-RECIPIENT (err u1010))

;; Data variables
(define-data-var contract-owner principal tx-sender)
(define-data-var transaction-nonce uint u0)
(define-data-var emergency-locked bool false)

;; Data maps
(define-map vaults
  { vault-id: uint }
  {
    signers: (list 10 principal),
    threshold: uint,
    balance: uint,
    is-active: bool
  }
)

(define-map vault-signers
  { vault-id: uint, signer: principal }
  { is-signer: bool }
)

(define-map pending-transactions
  { vault-id: uint, tx-id: uint }
  {
    recipient: principal,
    amount: uint,
    signatures: (list 10 principal),
    signature-count: uint,
    is-executed: bool,
    created-at: uint
  }
)

(define-map transaction-signatures
  { vault-id: uint, tx-id: uint, signer: principal }
  { has-signed: bool }
)

;; Private functions
(define-private (is-valid-principal (address principal))
  (not (is-eq address 'SP000000000000000000002Q6VF78))
)

(define-private (contains-principal (principals-list (list 10 principal)) (target principal))
  (> (len (filter is-target-principal principals-list)) u0)
)

(define-private (is-target-principal (p principal))
  (is-eq p tx-sender)
)

(define-private (validate-threshold (signers-count uint) (threshold uint))
  (and (> threshold u0) (<= threshold signers-count))
)

;; Read-only functions
(define-read-only (get-vault-info (vault-id uint))
  (begin
    (asserts! (> vault-id u0) none)
    (map-get? vaults { vault-id: vault-id })
  )
)

(define-read-only (is-vault-signer (vault-id uint) (signer principal))
  (begin
    (asserts! (> vault-id u0) false)
    (asserts! (is-valid-principal signer) false)
    (default-to false 
      (get is-signer 
        (map-get? vault-signers { vault-id: vault-id, signer: signer })
      )
    )
  )
)

(define-read-only (get-pending-transaction (vault-id uint) (tx-id uint))
  (begin
    (asserts! (> vault-id u0) none)
    (asserts! (> tx-id u0) none)
    (map-get? pending-transactions { vault-id: vault-id, tx-id: tx-id })
  )
)

(define-read-only (has-signed-transaction (vault-id uint) (tx-id uint) (signer principal))
  (begin
    (asserts! (> vault-id u0) false)
    (asserts! (> tx-id u0) false)
    (asserts! (is-valid-principal signer) false)
    (default-to false
      (get has-signed
        (map-get? transaction-signatures { vault-id: vault-id, tx-id: tx-id, signer: signer })
      )
    )
  )
)

(define-read-only (get-contract-owner)
  (var-get contract-owner)
)

(define-read-only (is-emergency-locked)
  (var-get emergency-locked)
)

(define-read-only (get-next-transaction-id)
  (var-get transaction-nonce)
)

;; Public functions
(define-public (create-vault (signers (list 10 principal)) (threshold uint))
  (let
    (
      (vault-id (+ (var-get transaction-nonce) u1))
      (signers-count (len signers))
    )
    (asserts! (> signers-count u0) ERR-INSUFFICIENT-SIGNERS)
    (asserts! (validate-threshold signers-count threshold) ERR-INVALID-THRESHOLD)
    (asserts! (< signers-count u11) ERR-INSUFFICIENT-SIGNERS)
    
    ;; Validate all signers are valid principals
    (asserts! (fold validate-signer-principal signers true) ERR-INVALID-RECIPIENT)
    
    ;; Create vault
    (map-set vaults
      { vault-id: vault-id }
      {
        signers: signers,
        threshold: threshold,
        balance: u0,
        is-active: true
      }
    )
    
    ;; Set signer mappings
    (fold set-vault-signer-mapping 
      (map add-vault-id signers) 
      vault-id
    )
    
    ;; Update transaction nonce
    (var-set transaction-nonce vault-id)
    
    (ok vault-id)
  )
)

(define-private (validate-signer-principal (signer principal) (prev-valid bool))
  (and prev-valid (is-valid-principal signer))
)

(define-private (add-vault-id (signer principal))
  { signer: signer, vault-id: (+ (var-get transaction-nonce) u1) }
)

(define-private (set-vault-signer-mapping (signer-data { signer: principal, vault-id: uint }) (vault-id uint))
  (begin
    (map-set vault-signers
      { vault-id: vault-id, signer: (get signer signer-data) }
      { is-signer: true }
    )
    vault-id
  )
)

(define-public (deposit-to-vault (vault-id uint) (amount uint))
  (let
    (
      (vault-data (unwrap! (map-get? vaults { vault-id: vault-id }) ERR-TRANSACTION-NOT-FOUND))
    )
    (asserts! (> vault-id u0) ERR-TRANSACTION-NOT-FOUND)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (get is-active vault-data) ERR-VAULT-LOCKED)
    (asserts! (not (var-get emergency-locked)) ERR-VAULT-LOCKED)
    
    ;; Transfer STX to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    ;; Update vault balance
    (map-set vaults
      { vault-id: vault-id }
      (merge vault-data { balance: (+ (get balance vault-data) amount) })
    )
    
    (ok true)
  )
)

(define-public (propose-transaction (vault-id uint) (recipient principal) (amount uint))
  (let
    (
      (vault-data (unwrap! (map-get? vaults { vault-id: vault-id }) ERR-TRANSACTION-NOT-FOUND))
      (tx-id (+ (var-get transaction-nonce) u1))
    )
    (asserts! (> vault-id u0) ERR-TRANSACTION-NOT-FOUND)
    (asserts! (is-vault-signer vault-id tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (is-valid-principal recipient) ERR-INVALID-RECIPIENT)
    (asserts! (get is-active vault-data) ERR-VAULT-LOCKED)
    (asserts! (not (var-get emergency-locked)) ERR-VAULT-LOCKED)
    (asserts! (<= amount (get balance vault-data)) ERR-INVALID-AMOUNT)
    
    ;; Create pending transaction
    (map-set pending-transactions
      { vault-id: vault-id, tx-id: tx-id }
      {
        recipient: recipient,
        amount: amount,
        signatures: (list tx-sender),
        signature-count: u1,
        is-executed: false,
        created-at: stacks-block-height
      }
    )
    
    ;; Record signature
    (map-set transaction-signatures
      { vault-id: vault-id, tx-id: tx-id, signer: tx-sender }
      { has-signed: true }
    )
    
    ;; Update nonce
    (var-set transaction-nonce tx-id)
    
    (ok tx-id)
  )
)

(define-public (sign-transaction (vault-id uint) (tx-id uint))
  (let
    (
      (vault-data (unwrap! (map-get? vaults { vault-id: vault-id }) ERR-TRANSACTION-NOT-FOUND))
      (tx-data (unwrap! (map-get? pending-transactions { vault-id: vault-id, tx-id: tx-id }) ERR-TRANSACTION-NOT-FOUND))
    )
    (asserts! (> vault-id u0) ERR-TRANSACTION-NOT-FOUND)
    (asserts! (> tx-id u0) ERR-TRANSACTION-NOT-FOUND)
    (asserts! (is-vault-signer vault-id tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (not (get is-executed tx-data)) ERR-TRANSACTION-ALREADY-EXECUTED)
    (asserts! (not (has-signed-transaction vault-id tx-id tx-sender)) ERR-ALREADY-SIGNED)
    (asserts! (get is-active vault-data) ERR-VAULT-LOCKED)
    (asserts! (not (var-get emergency-locked)) ERR-VAULT-LOCKED)
    
    ;; Add signature
    (map-set transaction-signatures
      { vault-id: vault-id, tx-id: tx-id, signer: tx-sender }
      { has-signed: true }
    )
    
    ;; Update transaction with new signature
    (map-set pending-transactions
      { vault-id: vault-id, tx-id: tx-id }
      (merge tx-data 
        { 
          signatures: (unwrap! (as-max-len? (append (get signatures tx-data) tx-sender) u10) ERR-INSUFFICIENT-SIGNERS),
          signature-count: (+ (get signature-count tx-data) u1)
        }
      )
    )
    
    (ok true)
  )
)

(define-public (execute-transaction (vault-id uint) (tx-id uint))
  (let
    (
      (vault-data (unwrap! (map-get? vaults { vault-id: vault-id }) ERR-TRANSACTION-NOT-FOUND))
      (tx-data (unwrap! (map-get? pending-transactions { vault-id: vault-id, tx-id: tx-id }) ERR-TRANSACTION-NOT-FOUND))
    )
    (asserts! (> vault-id u0) ERR-TRANSACTION-NOT-FOUND)
    (asserts! (> tx-id u0) ERR-TRANSACTION-NOT-FOUND)
    (asserts! (is-vault-signer vault-id tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (not (get is-executed tx-data)) ERR-TRANSACTION-ALREADY-EXECUTED)
    (asserts! (>= (get signature-count tx-data) (get threshold vault-data)) ERR-INSUFFICIENT-VOTES)
    (asserts! (get is-active vault-data) ERR-VAULT-LOCKED)
    (asserts! (not (var-get emergency-locked)) ERR-VAULT-LOCKED)
    (asserts! (<= (get amount tx-data) (get balance vault-data)) ERR-INVALID-AMOUNT)
    
    ;; Execute transfer
    (try! (as-contract (stx-transfer? (get amount tx-data) tx-sender (get recipient tx-data))))
    
    ;; Update vault balance
    (map-set vaults
      { vault-id: vault-id }
      (merge vault-data { balance: (- (get balance vault-data) (get amount tx-data)) })
    )
    
    ;; Mark transaction as executed
    (map-set pending-transactions
      { vault-id: vault-id, tx-id: tx-id }
      (merge tx-data { is-executed: true })
    )
    
    (ok true)
  )
)

(define-public (emergency-lock)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (var-set emergency-locked true)
    (ok true)
  )
)

(define-public (emergency-unlock)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (var-set emergency-locked false)
    (ok true)
  )
)