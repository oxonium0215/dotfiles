#!/bin/bash
# Setup mise and install tools
# This script runs once after chezmoi applies the dotfiles

set -euo pipefail

echo "==> Setting up mise and installing tools..."

# Ensure mise is in PATH (installed to ~/.local/bin by mise installer)
export PATH="$HOME/.local/bin:$PATH"

# Source cargo environment if available (for cargo packages)
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

# Ensure mise is available
if ! command -v mise &>/dev/null; then
    echo "Error: mise is not installed. Please run the install-packages script first."
    exit 1
fi

# Trust the mise config
mise trust --all

# Install all tools defined in the global config
echo "Installing tools via mise (this may take a while)..."
mise install

# Reshim to ensure all shims are up to date
mise reshim

# Verify key tools are installed
echo "Verifying tool installation..."
mise list

echo "==> mise setup completed successfully."
