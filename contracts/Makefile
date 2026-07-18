# ValoraSec Soroban Contracts Makefile
# Requires: Rust, Soroban CLI (stellar/soroban-cli)

.PHONY: all build test clean deploy deploy-testnet

# ─── Directories ────────────────────────────────────────────────────────

CONTRACTS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
AUDIT_REGISTRY := $(CONTRACTS_DIR)audit-registry
REPUTATION := $(CONTRACTS_DIR)reputation
BUG_BOUNTY := $(CONTRACTS_DIR)bug-bounty

# ─── Network ─────────────────────────────────────────────────────────────

NETWORK ?= testnet
SOROBAN_RPC_URL ?= https://soroban-testnet.stellar.org
SOROBAN_NETWORK_PASSPHRASE ?= "Test SDF Network ; September 2015"

# ─── Source Account ──────────────────────────────────────────────────────
# Set these via environment variables or export before running deploy.
# SOURCE_SECRET_KEY — Stellar secret key (S...)
# SOURCE_PUBLIC_KEY — Stellar public key (G...)

# ─── Targets ─────────────────────────────────────────────────────────────

all: build

## Build all contracts
build:
	@echo "Building audit-registry..."
	cd $(AUDIT_REGISTRY) && cargo build --target wasm32-unknown-unknown --release
	@echo "Building reputation..."
	cd $(REPUTATION) && cargo build --target wasm32-unknown-unknown --release
	@echo "Building bug-bounty..."
	cd $(BUG_BOUNTY) && cargo build --target wasm32-unknown-unknown --release
	@echo "All contracts built successfully."

## Run contract tests
test:
	@echo "Testing audit-registry..."
	cd $(AUDIT_REGISTRY) && cargo test
	@echo "Testing reputation..."
	cd $(REPUTATION) && cargo test
	@echo "Testing bug-bounty..."
	cd $(BUG_BOUNTY) && cargo test
	@echo "All tests passed."

## Clean build artifacts
clean:
	cd $(AUDIT_REGISTRY) && cargo clean
	cd $(REPUTATION) && cargo clean
	cd $(BUG_BOUNTY) && cargo clean

## Deploy all contracts to the configured network
deploy:
	@echo "Deploying all contracts to $(NETWORK)..."
	@bash $(CONTRACTS_DIR)scripts/deploy.sh

## Deploy to testnet (convenience target)
deploy-testnet:
	@NETWORK=testnet SOROBAN_RPC_URL=https://soroban-testnet.stellar.org $(MAKE) deploy

## Show contract IDs from deployed file
show-contracts:
	@if [ -f $(CONTRACTS_DIR).contract-ids ]; then \
		cat $(CONTRACTS_DIR).contract-ids; \
	else \
		echo "No .contract-ids file found. Run 'make deploy' first."; \
	fi

## Help
help:
	@echo "Available targets:"
	@echo "  build          - Build all contracts (wasm32)"
	@echo "  test           - Run all contract tests"
	@echo "  clean          - Clean build artifacts"
	@echo "  deploy         - Deploy all contracts to configured network"
	@echo "  deploy-testnet - Deploy to Stellar testnet"
	@echo "  show-contracts - Show deployed contract IDs"
