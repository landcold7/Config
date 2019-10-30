#!/usr/bin/env bash
# A wrapper to call todo.txt-cli

ROOT="$HOME/Util/todo.txt-cli/"
CONFIG="$HOME/.todo/todo.cfg"

"$ROOT/todo.sh" -d "$CONFIG" $*