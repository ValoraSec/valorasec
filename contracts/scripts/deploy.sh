#!/usr/bin/env bash
# ValoraSec Contract Deployment Script
# Deploys all three Soroban contracts to the Stellar testnet.
#
# Prerequisites:
#   1. Rust toolchain with wasm32-unknown-unknown target installed
#   2. Soroban CLI installed: cargo install soroban-cli
#   3. Configured Stellar identity with testnet funds
#
# Usage:
#   export SOURCE_SECRET_KEY="S..."  # Your Stellar secret key
#   bash contracts/scripts/deploy.sh
#
# Or use the Makefile:
#   make -C contracts deploy-testnet

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────

NETWORK="${NETWORK:-testnet}"
SOROBAN_RPC_URL="${SOROBAN_RPC_URL:-https://soroban-testnet.stellar.org}"
SOROBAN_NETWORK_PASSPHRASE="${SOROBAN_NETWORK_PASSPHRASE:-Test SDF Network ; September 2015}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTRACTS_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$CONTRACTS_DIR")"

# Contract directories
AUDIT_REGISTRY_DIR="$CONTRACTS_DIR/audit-registry"
REPUTATION_DIR="$CONTRACTS_DIR/reputation"
BUG_BOUNTY_DIR="$CONTRACTS_DIR/bug-bounty"

# Wasm artifacts (after build)
AUDIT_REGISTRY_WASM="$AUDIT_REGISTRY_DIR/target/wasm32-unknown-unknown/release/audit_registry.wasm"
REPUTATION_WASM="$REPUTATION_DIR/target/wasm32-unknown-unknown/release/reputation.wasm"
BUG_BOUNTY_WASM="$BUG_BOUNTY_DIR/target/wasm32-unknown-unknown/release/bug_bounty.wasm"

# Output file
CONTRACT_IDS_FILE="$CONTRACTS_DIR/.contract-ids"
ENV_EXAMPLE_FILE="$PROJECT_ROOT/.env.example"

# ─── Colors ──────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ─── Helpers ─────────────────────────────────────────────────────────────

log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    if ! command -v soroban &>/dev/null; then
        log_error "Soroban CLI not found. Install it with: cargo install soroban-cli"
        exit 1
    fi

    if ! command -v cargo &>/dev/null; then
        log_error "Rust/Cargo not found. Install from https://rustup.rs"
        exit 1
    }

    if [ -z "${SOURCE_SECRET_KEY:-}" ]; then
        log_warn "SOURCE_SECRET_KEY not set. Trying to use default identity..."
        # Check if there's a default identity
        if ! soroban config identity ls 2>/dev/null | grep -q .; then
            log_error "No Stellar identities found. Create one with:"
            log_error "  soroban config identity generate --global default --network testnet"
            log_error "  soroban config identity fund default --network testnet"
            log_error "Or set SOURCE_SECRET_KEY environment variable."
            exit 1
        fi
        SOURCE_FLAG=""
    else
        SOURCE_FLAG="--source-secret-key $SOURCE_SECRET_KEY"
    fi

    log_success "Prerequisites check passed."
}

build_contracts() {
    log_info "Building contracts (wasm32-unknown-unknown)..."

    log_info "Building audit-registry..."
    cd "$AUDIT_REGISTRY_DIR"
    cargo build --target wasm32-unknown-unknown --release

    log_info "Building reputation..."
    cd "$REPUTATION_DIR"
    cargo build --target wasm32-unknown-unknown --release

    log_info "Building bug-bounty..."
    cd "$BUG_BOUNTY_DIR"
    cargo build --target wasm32-unknown-unknown --release

    cd "$PROJECT_ROOT"

    for wasm in "$AUDIT_REGISTRY_WASM" "$REPUTATION_WASM" "$BUG_BOUNTY_WASM"; do
        if [ ! -f "$wasm" ]; then
            log_error "Wasm file not found: $wasm"
            exit 1
        fi
    done

    log_success "All contracts built successfully."
}

deploy_contract() {
    local name="$1"
    local wasm_path="$2"

    log_info "Deploying $name..."

    # Optimize the wasm (recommended for mainnet, optional for testnet)
    # soroban contract optimize --wasm "$wasm_path"

    # Deploy
    local deploy_output
    deploy_output=$(soroban contract deploy \
        --wasm "$wasm_path" \
        --rpc-url "$SOROBAN_RPC_URL" \
        --network-passphrase "$SOROBAN_NETWORK_PASSPHRASE" \
        $SOURCE_FLAG 2>&1)

    local contract_id
    contract_id=$(echo "$deploy_output" | tail -n 1 | tr -d '\n\r')

    if [[ ! "$contract_id" =~ ^C[A-Z0-9]{55}$ ]]; then
        log_error "Failed to deploy $name. Output: $deploy_output"
        exit 1
    fi

    log_success "$name deployed: $contract_id"
    echo "$contract_id"
}

verify_contract() {
    local name="$1"
    local contract_id="$2"
    local wasm_path="$3"

    log_info "Verifying $name ($contract_id)..."

    # Check contract exists on-chain
    if soroban contract info \
        --id "$contract_id" \
        --rpc-url "$SOROBAN_RPC_URL" \
        --network-passphrase "$SOROBAN_NETWORK_PASSPHRASE" &>/dev/null; then

        # Get the installed wasm hash
        local wasm_hash
        wasm_hash=$(soroban contract info \
            --id "$contract_id" \
            --rpc-url "$SOROBAN_RPC_URL" \
            --network-passphrase "$SOROBAN_NETWORK_PASSPHRASE" 2>&1 | grep -oP 'wasm hash:\s*\K[a-f0-9]+' || echo "N/A")

        log_success "$name verified. Wasm hash: $wasm_hash"
    else
        log_error "$name verification failed — contract not found on-chain."
        exit 1
    fi
}

write_contract_ids() {
    log_info "Writing contract IDs to $CONTRACT_IDS_FILE..."

    cat > "$CONTRACT_IDS_FILE" << EOF
# ValoraSec Contract IDs
# Network: ${NETWORK}
# Deployed: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
# RPC URL: ${SOROBAN_RPC_URL}

AUDIT_REGISTRY=${AUDIT_REGISTRY_ID}
REPUTATION=${REPUTATION_ID}
BUG_BOUNTY=${BUG_BOUNTY_ID}
EOF

    log_success "Contract IDs written to $CONTRACT_IDS_FILE"
}

update_env_example() {
    local env_file="$ENV_EXAMPLE_FILE"

    log_info "Updating env example with contract addresses..."

    if [ -f "$env_file" ]; then
        # Update existing env file
        if grep -q "AUDIT_REGISTRY_CONTRACT=" "$env_file"; then
            sed -i "s/^AUDIT_REGISTRY_CONTRACT=.*$/AUDIT_REGISTRY_CONTRACT=$AUDIT_REGISTRY_ID/" "$env_file"
        else
            echo "AUDIT_REGISTRY_CONTRACT=$AUDIT_REGISTRY_ID" >> "$env_file"
        fi
        if grep -q "REPUTATION_CONTRACT=" "$env_file"; then
            sed -i "s/^REPUTATION_CONTRACT=.*$/REPUTATION_CONTRACT=$REPUTATION_ID/" "$env_file"
        else
            echo "REPUTATION_CONTRACT=$REPUTATION_ID" >> "$env_file"
        fi
        if grep -q "BUG_BOUNTY_CONTRACT=" "$env_file"; then
            sed -i "s/^BUG_BOUNTY_CONTRACT=.*$/BUG_BOUNTY_CONTRACT=$BUG_BOUNTY_ID/" "$env_file"
        else
            echo "BUG_BOUNTY_CONTRACT=$BUG_BOUNTY_ID" >> "$env_file"
        fi
    else
        # Create new env example
        cat > "$env_file" << ENVEOF
# ValoraSec Environment Variables
# Generated by deploy.sh — $(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Stellar / Soroban
STELLAR_NETWORK=${NETWORK}
SOROBAN_RPC_URL=${SOROBAN_RPC_URL}

# Deployed Contract Addresses
AUDIT_REGISTRY_CONTRACT=${AUDIT_REGISTRY_ID}
REPUTATION_CONTRACT=${REPUTATION_ID}
BUG_BOUNTY_CONTRACT=${BUG_BOUNTY_ID}

# API
DATABASE_URL=postgresql://postgres:valorasec@localhost:5432/valorasec?schema=public
JWT_SECRET=change-me-to-a-strong-random-secret
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN_MS=604800000
PORT=4000
CORS_ORIGIN=http://localhost:3000
REDIS_URL=redis://localhost:6379
NODE_ENV=development

# Web
NEXT_PUBLIC_API_URL=http://localhost:4000
ENVEOF
    fi

    log_success "Environment file updated at $env_file"
}

# ─── Main ─────────────────────────────────────────────────────────────────

main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║     ValoraSec Contract Deployment — ${NETWORK}       ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo ""

    check_prerequisites
    build_contracts

    # Deploy contracts
    AUDIT_REGISTRY_ID=$(deploy_contract "audit-registry" "$AUDIT_REGISTRY_WASM")
    REPUTATION_ID=$(deploy_contract "reputation" "$REPUTATION_WASM")
    BUG_BOUNTY_ID=$(deploy_contract "bug-bounty" "$BUG_BOUNTY_WASM")

    # Verify contracts
    verify_contract "audit-registry" "$AUDIT_REGISTRY_ID" "$AUDIT_REGISTRY_WASM"
    verify_contract "reputation" "$REPUTATION_ID" "$REPUTATION_WASM"
    verify_contract "bug-bounty" "$BUG_BOUNTY_ID" "$BUG_BOUNTY_WASM"

    # Save results
    write_contract_ids
    update_env_example

    echo ""
    log_success "╔══════════════════════════════════╗"
    log_success "║   All contracts deployed!  ✓     ║"
    log_success "╚══════════════════════════════════╝"
    echo ""
    log_info "Contract IDs:"
    log_info "  Audit Registry : $AUDIT_REGISTRY_ID"
    log_info "  Reputation     : $REPUTATION_ID"
    log_info "  Bug Bounty     : $BUG_BOUNTY_ID"
    echo ""
    log_info "Next steps:"
    log_info "  1. Save contract IDs: contracts/.contract-ids"
    log_info "  2. Update your .env with the contract addresses"
    log_info "  3. Verify on Stellar Expert: https://stellar.expert/explorer/testnet"
    echo ""
}

main
