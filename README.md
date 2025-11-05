# AntCoin (ANT)

A SIP-010 compliant fungible token built with Clarity and managed with Clarinet.

- Name: AntCoin
- Symbol: ANT
- Decimals: 6

## Prerequisites

- Clarinet v3.7+ installed. Check: `clarinet --version`
- Node.js (optional, for the generated test tooling)

## Project structure

```
.
├── Clarinet.toml
├── contracts
│   ├── antcoin.clar            # AntCoin smart contract (implements SIP-010)
│   └── sip-010-trait.clar      # Local copy of the SIP-010 trait
├── settings                    # Network configuration templates
├── tests                       # Place JS/Vitest tests here
└── .vscode                     # VS Code helpers
```

## Quickstart

1) Install dependencies (if needed):
   - Linux/macOS: follow https://docs.hiro.so/clarity/clarinet
   - Verify: `clarinet --version`

2) Check contracts:

```bash
clarinet check
```

3) Open a local console to interact with the contract:

```bash
clarinet console
```

4) One-time: set the admin (should be done by the deployer immediately after deployment):

```clarity
(contract-call? .antcoin set-admin 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA)
```

## Contract overview

AntCoin is a minimal, owner-mintable SIP-010 fungible token implementation. The deployer (contract-owner) can mint new tokens; holders can transfer and burn their own tokens.

Key entrypoints in `contracts/antcoin.clar`:

- `(get-name) -> (ok "AntCoin")`
- `(get-symbol) -> (ok "ANT")`
- `(get-decimals) -> (ok u6)`
- `(get-total-supply) -> (ok <uint>)`
- `(get-balance <principal>) -> (ok <uint>)`
- `(transfer <amount> <sender> <recipient>) -> (ok true)`
- `(set-admin <principal>) -> (ok true)` [call once to set admin]
- `(get-admin) -> (some <principal>) | none`
- `(mint <amount> <recipient>) -> (ok true)`  [admin only]
- `(burn <amount> <sender>) -> (ok true)`

## Using Clarinet console

Start the console:

```bash
clarinet console
```

Example interactions (replace the principals as needed):

```clarity
;; Read metadata
(contract-call? .antcoin get-name)
(contract-call? .antcoin get-symbol)
(contract-call? .antcoin get-decimals)

;; Mint 1,000,000 ANT (with 6 decimals, this is 1.000000 ANT if you treat amounts as fixed-precision)
;; Must be called by the contract deployer
(contract-call? .antcoin mint u1000000 tx-sender)

;; Check balances
(contract-call? .antcoin get-balance tx-sender)

;; Transfer tokens
(contract-call? .antcoin transfer u500000 tx-sender 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA)

;; Burn tokens
(contract-call? .antcoin burn u100000 tx-sender)
```

Notes:
- Amounts are in the smallest unit (10^-6 of ANT).
- The first successful call to `set-admin` sets the admin; subsequent calls fail.
- `tx-sender` in the console defaults to the first devnet wallet; you can switch with `::set_tx_sender`.

## Testing

Place Vitest tests under `tests/`. Example test command:

```bash
npm install
npm test
```

## Deployment

- Use your preferred deployment flow (Clarinet + stacks.js, or deploy via a Stacks node/Explorer). Ensure you review and audit the contract before deploying to mainnet.

## License

This project is licensed under the MIT License. See `LICENSE` for details.
