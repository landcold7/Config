# set -x

action() {
  printf "\e[1;32m$*\e[m\n"
}

warning() {
  printf "\e[1;33m$*\e[m\n"
}

HISTSIZE=100000
SAVEHIST=10000
unsetopt flowcontrol
setopt hist_ignore_all_dups     # when runing a command several times, only store one
setopt hist_reduce_blanks       # reduce whitespace in history
setopt hist_ignore_space        # do not remember commands starting with space
setopt histfcntllock            # use F_SETLCKW
setopt share_history            # share history among sessions
setopt extended_history         # timestamp for each history entry
setopt hist_verify              # reload full command when runing from history
setopt hist_expire_dups_first   # remove dups when max size reached
setopt inc_append_history       # append to history once executed
setopt notify                   # report the status of backgrounds jobs immediately

typeset -U path
path=(~/bin ~/.local/bin "$path[@]")
fpath=(~/.zsh/functions $fpath)

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  action "Setup zprezto..."
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Aliases & functions {{{1
# General aliases & functions (partially shared with bash) {{{2
if [[ -f ~/.alias ]]; then
  action "Setup .alias..."
  # unalias -a
  source ~/.alias
fi

# Setup z.lua
if [[ -d ~/Util/z.lua ]]; then
  if [[ -n "$(command -v lua)" ]]; then
    action "Setup z.lua..."
    eval "$(lua ~/Util/z.lua/z.lua --init zsh once)"
  else
    warning "No 'lua' command find when trying to setup z.lua"
  fi
fi

# Setup fzf
if [[ -f ~/.fzf.zsh ]]; then
  action "Setup fzf..."
  source ~/.fzf.zsh
fi

# Setup extract.zsh
if [[ -f ~/Util/extract.zsh ]]; then
  action "Setup extract.zsh..."
  source ~/Util/extract.zsh
fi

# if [[ -f ~/Util/forgit/forgit.plugin.zsh ]]; then
#   action "Setup fzf forgit plugin..."
#   source ~/Util/forgit/forgit.plugin.zsh
# fi

# Setup a local zshrc
if [[ -s ~/.zshrc.local ]]; then
  action "Setup .zshrc.local..."
  source ~/.zshrc.local
fi

# Add a small split line before every cmds.
function preexec {
  echo "<_____________"
}

# https://unix.stackexchange.com/questions/90772/first-characters-of-the-command-repeated-in-the-display-when-completing
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8


