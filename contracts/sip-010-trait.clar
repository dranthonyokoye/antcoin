(define-trait sip-010-trait
  (
    ;; SIP-010 minimal trait for fungible tokens
    ;; https://github.com/stacksgov/sips/blob/main/sips/sip-010/sip-010-fungible-token-standard.md
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))
    (get-total-supply () (response uint uint))
    (get-balance (principal) (response uint uint))
    (transfer (uint principal principal) (response bool uint))
  )
)
