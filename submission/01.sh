#!/usr/bin/env bash
# Create a wallet with the name "btrustwallet".

set -euo pipefail

bitcoin-cli() {
  if [[ -n "${BITCOIN_DATADIR:-}" ]]; then
    command bitcoin-cli -datadir="$BITCOIN_DATADIR" "$@"
  else
    command bitcoin-cli "$@"
  fi
}

if bitcoin-cli -regtest listwallets | grep -q '"btrustwallet"'; then
  echo "btrustwallet"
elif bitcoin-cli -regtest loadwallet "btrustwallet" >/dev/null 2>&1; then
  echo "btrustwallet"
else
  bitcoin-cli -regtest createwallet "btrustwallet" >/dev/null
  echo "btrustwallet"
fi
