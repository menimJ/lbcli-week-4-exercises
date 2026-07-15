#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
DATA_DIR="$REPO_ROOT/.bitcoin"

exec bitcoin-cli -datadir="$DATA_DIR" -regtest "$@"
