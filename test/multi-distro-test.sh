#!/bin/bash
# Multi-distribution dotfiles test script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Test distributions
# Using an array of strings to avoid associative array issues in some bash versions (though 4.0+ is fine)
DISTROS=(
    "ubuntu:24.04|apt-get update && apt-get install -y sudo curl git ca-certificates"
    "debian:12|apt-get update && apt-get install -y sudo curl git ca-certificates"
    "fedora:40|dnf install -y sudo curl git"
    "archlinux:latest|pacman -Syu --noconfirm sudo curl git"
)

# Optional GitHub token
GITHUB_ARG=""
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    GITHUB_ARG="--build-arg GITHUB_TOKEN=${GITHUB_TOKEN}"
fi

results=()

for item in "${DISTROS[@]}"; do
    DISTRO="${item%%|*}"
    BOOTSTRAP="${item#*|}"
    
    log_step "Testing on $DISTRO..."
    IMAGE_NAME="dotfiles-test-${DISTRO//:/--}"
    
    echo "Building image for $DISTRO..."
    if ! docker build \
        $GITHUB_ARG \
        --build-arg SKIP_TEXLIVE_SETUP=true \
        --build-arg BASE_IMAGE="$DISTRO" \
        --build-arg BOOTSTRAP_COMMAND="$BOOTSTRAP" \
        -t "$IMAGE_NAME" "$PROJECT_ROOT"; then
        log_error "Failed to build image for $DISTRO"
        results+=("$DISTRO: BUILD FAILED")
        continue
    fi

    log_info "Applying chezmoi on $DISTRO..."
    # Run chezmoi apply and a few verifications
    if docker run --rm "$IMAGE_NAME" bash -c "
        set -ex
        # Apply chezmoi
        chezmoi apply --force
        
        # Basic verification
        test -f ~/.zshrc
        test -f ~/.config/mise/config.toml
        
        # Verify mise installation (it should be in PATH)
        export PATH=\"\$HOME/.local/bin:\$HOME/.local/share/mise/shims:\$PATH\"
        mise --version
        
        echo 'Verification successful!'
    "; then
        log_info "$DISTRO: PASSED"
        results+=("$DISTRO: PASSED")
    else
        log_error "$DISTRO: FAILED"
        results+=("$DISTRO: FAILED")
    fi
done

echo ""
echo "========================================"
echo " Summary of Multi-Distro Tests"
echo "========================================"
for res in "${results[@]}"; do
    if [[ "$res" == *"PASSED"* ]]; then
        echo -e "${GREEN}$res${NC}"
    else
        echo -e "${RED}$res${NC}"
    fi
done
echo "========================================"

# Exit with error if any test failed
for res in "${results[@]}"; do
    if [[ "$res" == *"FAILED"* ]]; then
        exit 1
    fi
done