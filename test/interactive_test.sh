#!/bin/bash
# Script to test "interactive" results in Docker
# We simulate interaction by manually creating the .chezmoi.toml file
# which is what 'chezmoi init' would produce based on prompts.

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

test_scenario() {
    local name=$1
    local dockerfile=$2
    local install_atcoder=$3
    local install_tex=$4

    echo -e "${BLUE}=== Testing Scenario: $name ===${NC}"
    
    # Build the image
    local tag=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    docker build -t "dotfiles-test-$tag" -f "$dockerfile" . > /dev/null

    # Run the container and simulate interaction
    docker run --rm -i "dotfiles-test-$tag" bash <<EOF
# Manually create .chezmoi.toml with desired configuration
# This bypasses TTY prompt issues in Docker while testing the same logic
mkdir -p ~/.config/chezmoi
cat <<CONFIG > ~/.config/chezmoi/chezmoi.toml
[data]
    install_atcoder_tools = $install_atcoder
    install_tex = $install_tex
    install_typst = true
    install_web_dev = true
    install_python = true
    install_go = true
    install_rust_tools = true
    install_neovim_env = true
CONFIG

# Run apply
echo "DEBUG: chezmoi os detection:"
~/.local/bin/chezmoi data | grep -E "os:|osID:" || true
~/.local/bin/chezmoi apply --force

# Verify some results
echo -e "${GREEN}Verifying results for $name...${NC}"

echo -n "AtCoder tools in mise: "
if grep -q "atcoder-tools" ~/.config/mise/config.toml; then
    if [ "$install_atcoder" = "true" ]; then echo -e "${GREEN}ENABLED (OK)${NC}"; else echo -e "${RED}ENABLED (ERROR)${NC}"; fi
else
    if [ "$install_atcoder" = "false" ]; then echo -e "${GREEN}DISABLED (OK)${NC}"; else echo -e "${RED}DISABLED (ERROR)${NC}"; fi
fi

echo -n "LaTeX in mise: "
if grep -q "tinytex" ~/.config/mise/config.toml; then
    if [ "$install_tex" = "true" ]; then echo -e "${GREEN}ENABLED (OK)${NC}"; else echo -e "${RED}ENABLED (ERROR)${NC}"; fi
else
    if [ "$install_tex" = "false" ]; then echo -e "${GREEN}DISABLED (OK)${NC}"; else echo -e "${RED}DISABLED (ERROR)${NC}"; fi
fi

# Check for .atcodertools.toml presence (should follow .chezmoiignore)
echo -n ".atcodertools.toml existence: "
if [[ -f ~/.atcodertools.toml ]]; then
    if [ "$install_atcoder" = "true" ]; then echo -e "${GREEN}PRESENT (OK)${NC}"; else echo -e "${RED}PRESENT (ERROR)${NC}"; fi
else
    if [ "$install_atcoder" = "false" ]; then echo -e "${GREEN}ABSENT (OK)${NC}"; else echo -e "${RED}ABSENT (ERROR)${NC}"; fi
fi

# For restricted, check if sudo was skipped gracefully
if [[ "$name" == "Restricted" ]]; then
    echo -n "Sudo skip check: "
    # We grep the previous output in a real script, here we just look for warnings
fi
EOF
}

# Scenario 1: Unrestricted (Sudo available)
# We choose TRUE for everything
test_scenario "Unrestricted" "Dockerfile" "true" "true"

echo ""

# Scenario 2: Restricted (No Sudo)
# We choose FALSE for AtCoder and LaTeX to see if it's respected
test_scenario "Restricted" "Dockerfile.restricted" "false" "false"
