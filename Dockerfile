# Dockerfile for testing dotfiles
# Usage: docker build -t dotfiles-test . && docker run --rm -it dotfiles-test
# With GitHub token: docker build --build-arg GITHUB_TOKEN=xxx -t dotfiles-test .

FROM ubuntu:24.04

# GitHub token for avoiding API rate limits (optional)
ARG GITHUB_TOKEN
ENV GITHUB_TOKEN=${GITHUB_TOKEN}
# mise uses GITHUB_API_TOKEN
ENV GITHUB_API_TOKEN=${GITHUB_TOKEN}

# Skip TinyTeX package installation (for faster testing)
ARG SKIP_TEXLIVE_SETUP=false
ENV SKIP_TEXLIVE_SETUP=${SKIP_TEXLIVE_SETUP}

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
# Neovim headless execution
ENV TERM=xterm-256color

# Install base packages + Neovim dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    git \
    unzip \
    ca-certificates \
    locales \
    # Neovim dependencies
    xclip \
    ripgrep \
    fd-find \
    # Build tools (treesitter, telescope, etc.)
    gcc \
    g++ \
    make \
    # Required for tree-sitter-cli compilation
    libclang-dev \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

# Create test user with sudo privileges
RUN useradd -m -s /bin/bash testuser && \
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# Install chezmoi
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# Set PATH for mise and local binaries
ENV PATH="/home/testuser/.local/bin:/home/testuser/.local/share/mise/shims:/home/testuser/.local/share/bob/nvim-bin:${PATH}"

# Copy dotfiles repository
COPY --chown=testuser:testuser . /home/testuser/.local/share/chezmoi

CMD ["bash"]
