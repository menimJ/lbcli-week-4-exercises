#!/usr/bin/env bash
# Create a wallet with the name "btrustwallet".

set -euo pipefail

BITCOIN_ARGS=()
if [[ -n "${BITCOIN_DATADIR:-}" ]]; then
  BITCOIN_ARGS+=(-datadir="$BITCOIN_DATADIR")
fi

bitcoin-cli() {
  command bitcoin-cli "${BITCOIN_ARGS[@]}" "$@"
}

if bitcoin-cli -regtest listwallets | grep -q '"btrustwallet"'; then
  echo "btrustwallet"
elif bitcoin-cli -regtest loadwallet "btrustwallet" >/dev/null 2>&1; then
  echo "btrustwallet"
else
  bitcoin-cli -regtest createwallet "btrustwallet" >/dev/null
  echo "btrustwallet"
fi
