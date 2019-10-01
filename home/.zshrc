action() {
  printf "\e[1;32m$*\e[m\n"
}

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
  source ~/.alias
fi

# Setup z.lua
if [[ -d ~/Util/z.lua ]]; then
  action "Setup z.lua..."
  eval "$(lua ~/Util/z.lua/z.lua --init zsh once)"
fi

# Setup fzf
if [[ -f ~/.fzf.zsh ]]; then
  action "Setup fzf..."
  source ~/.fzf.zsh
fi

# Setup a local zshrc
if [[ -s ~/.zshrc.local ]]; then 
  action "Setup .zshrc.local..."
  source ~/.zshrc.local
fi

# Add a small split line before every cmds.
function preexec {
  echo "<_____________"
}



