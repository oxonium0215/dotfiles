########################################
# 環境変数
export LANG=en_US.UTF-8
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH=$PNPM_HOME:$PATH
export PATH=$HOME/go/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/.local/share/bob/nvim-bin:$PATH
export PATH=$HOME/.pixi/bin:$PATH
export PATH=$HOME/.bun/bin:$PATH
export PATH=/snap/bin:$PATH
export PATH=/usr/local/cuda/bin:$PATH

export PATH="$PATH:/usr/local/texlive/2025/bin/x86_64-linux"
export MANPATH="$MANPATH:/usr/local/texlive/2025/texmf-dist/doc/man"
export INFOPATH="$INFOPATH:/usr/local/texlive/2025/texmf-dist/doc/info"

export EDITOR=nvim
export SHELL=/bin/zsh
export MANPAGER='nvim +Man!'
export ZF_PROMPT=`echo "\033[36mzf ❯ \033[m"`
# Check if sccache is available
if command -v sccache >/dev/null 2>&1; then
  export RUSTC_WRAPPER=sccache
fi
# colorize
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# LuaTeX Cache Environment Variables
export TEXMFCACHE="$HOME/.cache/texlive"
export TEXMFVAR="$HOME/.cache/texlive"
export LUAOTFLOAD_CACHE_DIR="$HOME/.cache/luatex/luaotfload"
export LUATEX_CACHE_DIR="$HOME/.cache/luatex"
export LUAOTFLOAD_NAMES_DIR="$HOME/.cache/luatex/luaotfload/names"

# Ensure cache directories exist on shell startup
if [[ ! -d "$LUAOTFLOAD_CACHE_DIR" ]]; then
    mkdir -p "$LUAOTFLOAD_CACHE_DIR/names"
    mkdir -p "$LUAOTFLOAD_CACHE_DIR/fonts"
    chmod -R 755 "$HOME/.cache/luatex"
fi

########################################
# alias
alias lst='eza -ltr --color=auto --icons'
alias l='eza -ltr --color=auto --icons'
alias ls='eza -a --icons'
alias la='eza -la --color=auto --icons'
alias ll='eza -l --color=auto --icons'
alias vi='nvim'
alias atc='atcoder-tools'
alias docker-purge='docker stop $(docker ps -q) && docker rmi $(docker images -q) -f'
# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '
# グローバルエイリアス
alias -g L='| less'
alias -g H='| head'
alias -g G='| grep'
alias -g GI='| grep -ri'

alias sudoe='sudo env PATH=$PATH'

########################################
# functions
zle-cd() {
  local dir=$(z | while IFS= read -r line; do echo ${line##* }; done | zf)
  if [ -z "$dir" ];then
    zle reset-prompt
    return 0
  fi
  BUFFER="cd $dir"
  zle reset-prompt
  zle accept-line
}
zle -N zle-cd
bindkey '^j' zle-cd

# hooks
chpwd() {
 if [[ $(pwd) != $HOME ]]; then
   eza -a --group-directories-first
 fi
}

# どこからでも参照できるディレクトリパス
cdpath=(~)
# others
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
else
  schedule_warning "%F{yellow}Warning: 'mise' is not installed. Tool version management is disabled.%f"
fi

# Check for 'zf' which is used in zle-cd
if ! command -v zf >/dev/null 2>&1; then
  schedule_warning "%F{yellow}Warning: 'zf' is not installed. 'Ctrl+j' (zle-cd) will not work.%f"
fi

########################################
# 補完
# 補完機能を有効にする
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.m-1) ]]; then
  compinit -C
else
  compinit
fi
# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..
# 補完の見た目を変更
zstyle ':completion:*' menu select
# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
  /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

########################################
# git設定 (vcs_info)
autoload -Uz vcs_info
autoload -Uz add-zsh-hook
setopt prompt_subst

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats "%F{red}%c%u[%b|%a]%f"

function _update_vcs_info_msg() {
    vcs_info
    RPROMPT="${vcs_info_msg_0_}"
}
add-zsh-hook precmd _update_vcs_info_msg

# SSH Agent Forwarding for Bitwarden
# Run only in WSL
if grep -qE "(Microsoft|WSL)" /proc/version; then
    # Check dependencies
    if ! command -v socat >/dev/null 2>&1; then
        schedule_warning "%F{yellow}Warning: 'socat' is not installed. Bitwarden SSH Agent forwarding is disabled.%f"
    elif ! command -v npiperelay.exe >/dev/null 2>&1; then
        schedule_warning "%F{yellow}Warning: 'npiperelay.exe' is not found in PATH. Bitwarden SSH Agent forwarding is disabled.%f"
    else
        export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock

        if ! ss -xl | grep -q "$SSH_AUTH_SOCK"; then
            rm -f "$SSH_AUTH_SOCK"
            NPIPERELAY_BIN=$(command -v npiperelay.exe)
            (setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"$NPIPERELAY_BIN -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
            
            # Wait for socket to be created (max 0.5s)
            local i
            for i in {1..10}; do
                if [[ -S "$SSH_AUTH_SOCK" ]]; then
                    break
                fi
                sleep 0.05
            done
        fi

        timeout 1s ssh-add -l >/dev/null 2>&1
        local ret=$?
        if [ $ret -eq 2 ] || [ $ret -eq 124 ]; then
            schedule_warning "%F{red}Bitwarden SSH Agent connection failed. Fallback to standard SSH agent.%f"
            unset SSH_AUTH_SOCK
        fi
    fi
fi
