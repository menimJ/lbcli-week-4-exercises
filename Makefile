ARGS ?=
SCRIPT ?=
BITCOIN_DATADIR := $(PWD)/.bitcoin

.PHONY: start-bitcoin bcli status-bitcoin stop-bitcoin
.PHONY: run
.PHONY: test-submissions

start-bitcoin:
	./tools/setup-local-bitcoin.sh

bcli:
	./tools/bcli.sh $(ARGS)

status-bitcoin:
	./tools/bcli.sh getblockchaininfo

stop-bitcoin:
	./tools/bcli.sh stop

run: start-bitcoin
	@if [ -z "$(SCRIPT)" ]; then \
		echo 'Usage: make run SCRIPT=01'; \
		exit 1; \
	fi
	BITCOIN_DATADIR="$(BITCOIN_DATADIR)" bash submission/$(SCRIPT).sh

test-submissions: start-bitcoin
	@for script in 01 02 03 04 05 06 07; do \
		echo "Running submission/$$script.sh"; \
		BITCOIN_DATADIR="$(BITCOIN_DATADIR)" bash "submission/$$script.sh" || exit 1; \
	done
