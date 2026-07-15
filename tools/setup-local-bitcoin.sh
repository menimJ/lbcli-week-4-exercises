#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
DATA_DIR="$REPO_ROOT/.bitcoin"
CONF_FILE="$DATA_DIR/bitcoin.conf"

mkdir -p "$DATA_DIR"

if "$SCRIPT_DIR/bcli.sh" getblockchaininfo >/dev/null 2>&1; then
  echo "Local regtest node is already running."
  exit 0
fi

pick_port() {
  local requested_port=$1

  python3 - "$requested_port" <<'PY'
import socket
import sys

requested = int(sys.argv[1])

def port_is_free(port: int) -> bool:
    for host in ("127.0.0.1", "::1"):
        family = socket.AF_INET6 if ":" in host else socket.AF_INET
        try:
            with socket.socket(family, socket.SOCK_STREAM) as sock:
                sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                sock.bind((host, port))
        except OSError:
            return False
    return True

if port_is_free(requested):
    print(requested)
    sys.exit(0)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
    sock.bind(("127.0.0.1", 0))
    print(sock.getsockname()[1])
PY
}

RPC_PORT=$(pick_port "${RPC_PORT:-29443}")
P2P_PORT=$(pick_port "${P2P_PORT:-29444}")

cat > "$CONF_FILE" <<EOF
regtest=1

[regtest]
rpcuser=user
rpcpassword=password
rpcport=$RPC_PORT
port=$P2P_PORT
fallbackfee=0.0001
EOF

bitcoind -datadir="$DATA_DIR" -daemon

echo "Waiting for local regtest node to become ready..."
for _ in $(seq 1 30); do
  if "$SCRIPT_DIR/bcli.sh" getblockchaininfo >/dev/null 2>&1; then
    echo "Local regtest node is ready."
    exit 0
  fi
  sleep 1
done

echo "ERROR: Local regtest node did not become ready in time."
exit 1
