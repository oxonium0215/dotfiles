#######################################
# オプション

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
# source ~/proxy_scripts/shudo.sh

# 日本語ファイル名を表示可能にする
export LANG=en_US.UTF-8
setopt print_eight_bit
# beep を無効にする
setopt no_beep
unsetopt beep
# Ctrl+Dでzshを終了しない
setopt ignore_eof
# '#' 以降をコメントとして扱う
setopt interactive_comments
setopt EXTENDED_HISTORY
# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups
# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space
# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks
setopt hist_no_store
# 同時に起動したzshの間でヒストリを共有する
setopt share_history
# ディレクトリ名だけでcdする
setopt auto_cd
# cd したら自動的にpushdする
setopt auto_pushd
# 重複したディレクトリを追加しない
setopt pushd_ignore_dups
# 高機能なワイルドカード展開を使用する
setopt extended_glob
# フローコントロールを無効にする
setopt noflowcontrol
# コマンドミスを修正
setopt correct

# 色を使用出来るようにする
autoload -Uz colors
colors

########################################
# キーバインド

# vi mode
bindkey -v
KEYTIMEOUT=2
# bindings
bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
bindkey "^[[3~" delete-char
bindkey "^[[1~" beginning-of-line
bindkey "^[[H" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[[F" end-of-line
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line

########################################
# OS 別の設定
case ${OSTYPE} in
    darwin*)
        #Mac用の設定
        export CLICOLOR=1
        alias ls='ls -G -F'
        ;;
    linux*)
        #Linux用の設定
        alias ls='ls -F --color=auto'
        ;;
esac

# プロンプト
PROMPT="%(?.%{${fg[green]}%}.%{${fg[red]}%})%n${reset_color}@${fg[blue]}%m${reset_color}(%*%) %~
%# "

# setup Deno
export DENO_INSTALL="$HOME/.deno"
export PATH=$DENO_INSTALL/bin:$PATH


