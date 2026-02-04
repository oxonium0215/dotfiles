#!/bin/bash
# Finalize dotfiles setup
# This script runs after every chezmoi apply

set -euo pipefail

echo "==> Finalizing dotfiles setup..."

# Generate sheldon plugin cache if sheldon is available
if command -v sheldon &>/dev/null; then
    SHELDON_CONFIG="$HOME/.config/zsh/sheldon/plugins.toml"
    if [[ -f "$SHELDON_CONFIG" ]]; then
        echo "Generating sheldon plugin cache..."
        # --config-file is a global option, must come before subcommand
        sheldon --config-file "$SHELDON_CONFIG" lock
        sheldon --config-file "$SHELDON_CONFIG" source > "$HOME/.config/zsh/sheldon/sheldon.zsh"
    fi
fi

# Compile zsh files for faster loading (optional, creates .zwc files)
# Uncomment if you want to enable zcompile
# if command -v zsh &>/dev/null; then
#     echo "Compiling zsh files..."
#     for f in ~/.zshrc ~/.config/zsh/*.zsh; do
#         [[ -f "$f" ]] && zsh -c "zcompile '$f'" 2>/dev/null || true
#     done
# fi

# Set zsh as default shell if not already
if [[ "$SHELL" != */zsh ]]; then
    if command -v zsh &>/dev/null; then
        ZSH_PATH=$(command -v zsh)
        if grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
            echo "Setting zsh as default shell..."
            chsh -s "$ZSH_PATH" || echo "Warning: Could not change default shell. Run 'chsh -s $ZSH_PATH' manually."
        else
            echo "Warning: $ZSH_PATH is not in /etc/shells. Add it first with:"
            echo "  echo '$ZSH_PATH' | sudo tee -a /etc/shells"
            echo "  chsh -s '$ZSH_PATH'"
        fi
    fi
fi

echo "==> Dotfiles setup complete!"
echo ""
echo "Please restart your shell or run 'exec zsh' to apply changes."
