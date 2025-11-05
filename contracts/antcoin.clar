;; AntCoin - SIP-010 fungible token implementation
;; Admin can mint new tokens; holders can transfer and burn.

(impl-trait .sip-010-trait.sip-010-trait)

;; Error codes
(define-constant ERR-NON-POSITIVE-AMOUNT u100)
(define-constant ERR-NOT-AUTHORIZED u101)
(define-constant ERR-INSUFFICIENT-BALANCE u102)

;; Token metadata
(define-constant TOKEN-NAME "AntCoin")
(define-constant TOKEN-SYMBOL "ANT")
(define-constant TOKEN-DECIMALS u6)

;; Storage
(define-data-var total-supply uint u0)
(define-map balances { account: principal } { balance: uint })
(define-data-var admin (optional principal) none)

;; Admin management
(define-public (set-admin (who principal))
  (begin
    (match (var-get admin)
      some-admin (err ERR-NOT-AUTHORIZED) ;; already set
      (begin (var-set admin (some who)) (ok true))
    )
  )
)

(define-read-only (get-admin)
  (var-get admin)
)

;; Helpers
(define-read-only (get-balance-internal (who principal))
  (default-to u0 (get balance (map-get? balances { account: who }))))

(define-private (credit! (who principal) (amount uint))
  (let ((cur (get-balance-internal who)))
    (map-set balances { account: who } { balance: (+ cur amount) })
  )
)

(define-private (debit! (who principal) (amount uint))
  (let ((cur (get-balance-internal who)))
    (if (>= cur amount)
        (begin
          (map-set balances { account: who } { balance: (- cur amount) })
          true)
        false)
  )
)

;; SIP-010 trait functions
(define-read-only (get-name)
  (ok TOKEN-NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN-SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN-DECIMALS)
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-balance (who principal))
  (ok (get-balance-internal who))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (> amount u0) (err ERR-NON-POSITIVE-AMOUNT))
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (debit! sender amount) (err ERR-INSUFFICIENT-BALANCE))
    (credit! recipient amount)
    (ok true)
  )
)

;; Extensions
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (> amount u0) (err ERR-NON-POSITIVE-AMOUNT))
    (match (var-get admin)
      a (begin
          (asserts! (is-eq tx-sender a) (err ERR-NOT-AUTHORIZED))
          (var-set total-supply (+ (var-get total-supply) amount))
          (credit! recipient amount)
          (ok true)
        )
      (err ERR-NOT-AUTHORIZED)
    )
  )
)

(define-public (burn (amount uint) (sender principal))
  (begin
    (asserts! (> amount u0) (err ERR-NON-POSITIVE-AMOUNT))
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (debit! sender amount) (err ERR-INSUFFICIENT-BALANCE))
    (var-set total-supply (- (var-get total-supply) amount))
    (ok true)
  )
)
