#!/bin/bash
# Finalize dotfiles setup
# This script runs after every chezmoi apply

set -euo pipefail

echo "==> Finalizing dotfiles setup..."



# Compile zsh files for faster loading (optional, creates .zwc files)
if command -v zsh &>/dev/null; then
    echo "Compiling zsh files..."
    for f in ~/.zshrc ~/.config/zsh/*.zsh; do
        [[ -f "$f" ]] && zsh -c "zcompile '$f'" 2>/dev/null || true
    done
fi

# Set zsh as default shell if not already
if [[ "$SHELL" != */zsh ]]; then
    if command -v zsh &>/dev/null; then
        ZSH_PATH=$(command -v zsh)
        if grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
            echo "Setting zsh as default shell..."
            if chsh -s "$ZSH_PATH"; then
                echo "Successfully changed default shell to zsh."
            else
                echo "Warning: Could not change default shell with chsh."
                echo "If you don't have permission to change your login shell, you can manually"
                echo "add 'exec $ZSH_PATH -l' to your .bashrc or .profile."
            fi
        else
            echo "Warning: $ZSH_PATH is not in /etc/shells."
            echo "To use zsh as your default shell, add it to /etc/shells first (requires sudo):"
            echo "  echo '$ZSH_PATH' | sudo tee -a /etc/shells"
            echo "  chsh -s '$ZSH_PATH'"
            echo ""
            echo "If you don't have sudo permissions, you can manually start zsh by adding"
            echo "the following to your .bashrc or .profile:"
            echo "  [ -t 0 ] && export SHELL=$ZSH_PATH && exec $ZSH_PATH -l"
        fi
    fi
fi

echo "==> Dotfiles setup complete!"
echo ""
echo "Please restart your shell or run 'exec zsh' to apply changes."
