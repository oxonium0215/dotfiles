#!/bin/bash
# Docker-based dotfiles test script
# Tests chezmoi apply, mise setup, Neovim plugins, and Mason tools

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

IMAGE_NAME="dotfiles-test"
CONTAINER_NAME="dotfiles-test-$$"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

cleanup() {
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
}
trap cleanup EXIT

# Parse arguments
SKIP_TEXLIVE=false
SKIP_NEOVIM=false
INTERACTIVE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-texlive) SKIP_TEXLIVE=true; shift ;;
        --skip-neovim) SKIP_NEOVIM=true; shift ;;
        -i|--interactive) INTERACTIVE=true; shift ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --skip-texlive   Skip TinyTeX package installation"
            echo "  --skip-neovim    Skip Neovim plugin/LSP test"
            echo "  -i, --interactive   Run interactive shell after tests"
            echo "  -h, --help       Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  GITHUB_TOKEN     GitHub token to avoid API rate limits"
            exit 0 ;;
        *) shift ;;
    esac
done

echo "========================================"
echo " Dotfiles Docker Test"
echo "========================================"
echo ""

# Build with optional GitHub token and skip flags
BUILD_ARGS=""
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    log_info "Using GITHUB_TOKEN for API rate limit avoidance"
    BUILD_ARGS="--build-arg GITHUB_TOKEN=${GITHUB_TOKEN}"
fi
if [[ "$SKIP_TEXLIVE" == "true" ]]; then
    log_info "Skipping TinyTeX package installation"
    BUILD_ARGS="$BUILD_ARGS --build-arg SKIP_TEXLIVE_SETUP=true"
fi

log_step "Building Docker image..."
docker build $BUILD_ARGS -t "$IMAGE_NAME" "$PROJECT_ROOT"

echo ""
log_step "Test 1: chezmoi diff (dry-run)..."
echo "----------------------------------------"
docker run --rm --name "${CONTAINER_NAME}-diff" "$IMAGE_NAME" chezmoi diff || true

echo ""
log_step "Test 2: chezmoi apply --exclude=scripts (config files only)..."
echo "----------------------------------------"
docker run --rm --name "${CONTAINER_NAME}-config" "$IMAGE_NAME" \
    bash -c "chezmoi apply --exclude=scripts && echo '' && echo '=== Home directory ===' && ls -la ~"

echo ""
log_step "Test 3-7: Full installation and verification..."
echo "----------------------------------------"
log_warn "This may take 10-20 minutes for full installation..."

# Create a persistent container for all remaining tests
docker create --name "$CONTAINER_NAME" "$IMAGE_NAME" sleep infinity
docker start "$CONTAINER_NAME"

# Helper function to run commands in the container
run_in_container() {
    docker exec "$CONTAINER_NAME" bash -c "$1"
}

echo ""
echo "=== Test 3: Full chezmoi apply (with scripts) ==="
run_in_container "chezmoi apply -v 2>&1"

echo ""
echo "=== Test 4: Verifying mise tools ==="
run_in_container '
    export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
    echo "=== mise version ==="
    mise --version || echo "mise not available"
    echo ""
    echo "=== mise list ==="
    mise list || echo "No tools installed"
    echo ""
    echo "=== bob (nvim version manager) ==="
    bob list 2>/dev/null || echo "bob not ready yet"
'

# Neovim tests
if [ "$SKIP_NEOVIM" = false ]; then
    echo ""
    echo "=== Test 5: Neovim installation and startup ==="
    run_in_container '
        export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$HOME/.local/share/bob/nvim-bin:$PATH"
        
        echo "=== Installing Neovim via bob ==="
        bob install stable
        bob use stable
        
        echo ""
        echo "=== Neovim version ==="
        nvim --version | head -5
        
        echo ""
        echo "=== Installing plugins via lazy.nvim ==="
        # Run headless and sync plugins
        timeout 300 nvim --headless "+Lazy! sync" +qa 2>&1 || true
        
        echo ""
        echo "=== Installed plugins ==="
        ls ~/.local/share/nvim/lazy/ 2>/dev/null | head -20 || echo "No plugins found"
        PLUGIN_COUNT=$(ls ~/.local/share/nvim/lazy/ 2>/dev/null | wc -l || echo 0)
        echo ""
        echo "Total plugins: $PLUGIN_COUNT"
    '
    
    echo ""
    echo "=== Test 6: Mason tools installation ==="
    log_warn "Testing Mason auto-install (this may take a few minutes)..."
    run_in_container '
        export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$HOME/.local/share/bob/nvim-bin:$PATH"
        
        echo "=== Testing Mason auto-install for Lua filetype ==="
        # Open a Lua file to trigger Mason auto-install
        timeout 180 nvim --headless -c "edit /tmp/test.lua" -c "sleep 90" -c "qa!" 2>&1 || true
        
        echo ""
        echo "=== Installed Mason packages ==="
        ls ~/.local/share/nvim/mason/packages/ 2>/dev/null || echo "No Mason packages yet"
        
        echo ""
        echo "=== Mason bin tools ==="
        ls ~/.local/share/nvim/mason/bin/ 2>/dev/null || echo "No Mason bin tools yet"
    '
fi

echo ""
echo "=== Test 7: zsh startup test ==="
run_in_container '
    export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
    echo "=== zsh version ==="
    zsh --version
    echo ""
    echo "=== zsh startup test ==="
    # Test zsh can start and source config
    zsh -i -c "echo zsh started successfully; exit 0" 2>&1 || echo "zsh startup had warnings (may be normal in container)"
'

# TinyTeX verification (if not skipped)
if [ "$SKIP_TEXLIVE" = false ]; then
    echo ""
    echo "=== Test 8: TinyTeX verification ==="
    run_in_container '
        if [[ -d "$HOME/.TinyTeX" ]] || command -v tlmgr &>/dev/null; then
            echo "=== TinyTeX installation found ==="
            
            # Check mise-managed location
            if command -v mise &>/dev/null; then
                MISE_TINYTEX=$(mise where tinytex 2>/dev/null || true)
                if [[ -n "$MISE_TINYTEX" ]]; then
                    echo "TinyTeX location: $MISE_TINYTEX"
                fi
            fi
            
            # Find tlmgr
            TLMGR=$(which tlmgr 2>/dev/null || find "$HOME" -name "tlmgr" -type f 2>/dev/null | head -1)
            if [[ -n "$TLMGR" ]]; then
                echo ""
                echo "=== Installed TeX packages (sample) ==="
                "$TLMGR" list --only-installed 2>/dev/null | head -20 || echo "Could not list packages"
            fi
        else
            echo "TinyTeX not installed (may have been skipped)"
        fi
    '
fi

# Stop container
docker stop "$CONTAINER_NAME" >/dev/null

echo ""
echo "========================================"
log_info "All tests completed!"
echo "========================================"

# Interactive mode
if [ "$INTERACTIVE" = true ]; then
    echo ""
    log_info "Starting interactive shell..."
    docker start "$CONTAINER_NAME"
    docker exec -it "$CONTAINER_NAME" bash
fi
