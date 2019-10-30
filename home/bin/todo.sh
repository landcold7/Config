#!/usr/bin/env bash
# A wrapper to call todo.txt-cli

ROOT="$HOME/Util/todo.txt-cli/"
CONFIG="$HOME/.todo/todo.cfg"

"$ROOT/todo.sh" -d "$CONFIG" $*

# After each action, it will rewrite todo.txt, thus
# here we make a explicit relink.
CONFIG_TXT="$HOME/Config/home/.todo"
HOME_TXT="$HOME/.todo"
if [[ ! -L "$HOME_TXT/todo.txt" ]]; then
  cp -f "$HOME_TXT/todo.txt" "$CONFIG_TXT/todo.txt"
  ln -sf "$CONFIG_TXT/todo.txt" "$HOME_TXT/todo.txt"

  cp -f "$HOME_TXT/todo.txt.bak" "$CONFIG_TXT/todo.txt.bak"
  ln -sf "$CONFIG_TXT/todo.txt.bak" "$HOME_TXT/todo.txt.bak"
fi