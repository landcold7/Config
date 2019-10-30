#!/usr/bin/env bash
set -e
# set -x

exclude="\
backup|\
.tmux\
"

files=($(git ls-files | egrep -v "$exclude"))

target=~
LN_OPT=-sf
[[ $(uname -s) == Linux ]] && LN_OPT=-sfr

# Declare a associative array, Newer bash has this feature.
# Link the whole directry instead of linking every file in this dir.
declare -A dir
# dir[.vim]=1
dir[.tmux]=1
dir[.todo.actions.d]=1
dir[.todo]=1G

info() {
  printf "\e[1;36m$*\e[m\n"
}

action() {
  printf "\e[1;32m$*\e[m\n"
}

warning() {
  printf "\e[1;33m$*\e[m\n"
}

link() {
  ln "$LN_OPT" "$PWD/$1" "$2"
}

do_ssh() {
  #cp -auT home/.ssh ~/.ssh
  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/*
}

do_mkdir() {
  mkdir -p ~/{.history,tmp}
  mkdir -p ~/.vimtmp/{backup,swap,undo}
  # mkdir -p ~/Wallpapers ~/.local/opt
}

do_git() {
  # Updates all submodules contained in this repo.
  git submodule update --init --recursive
}

fix_platform() {
  # fix prezto
  # By default, this `✘` special sign casues ugly alignment problem.
  sed -i.bak 's/local show_return="✘ "/local show_return="x "/g' \
      ~/.zprezto/modules/prompt/functions/prompt_sorin_setup

  # fix tmux plugin according to os
  if [[ $(uname -s) == Darwin ]]; then
    sed -i.bak 's/xdg-open/open/g' \
      ~/.tmux/plugins/tmux-url-select/tmux-url-select.pl
  fi
}

load_service() {
  # Load all launchd services for osx.
  if [[ $(uname -s) != Darwin ]]; then
    info "Service: Not on osx platform" && return
  fi
  local SERVICE=~/Library/LaunchAgents
  rm -f /tmp/me@*
  for srv in $(ls $SERVICE/me@*.plist); do
    action "Launchd $srv..."
    launchctl unload -w "$srv"
    launchctl load -w "$srv"
  done
}

check_skip() {
  local ff=${f/"$1"\//}
  local skip=
  while : ; do
    # Try every level of the path to see whether
    # its already been processed before.
    [[ ${dir[$ff]+_} ]] && skip=1
    [[ $ff =~ / ]] || break
    ff=${ff%/*}
  done
  if [[ -n $skip ]]; then
    return 0
  else
    return 1
  fi
}

check_link() {
# Check whether a soft link exists and doesn't point to Config repo
  local soft="$1"
  if [[ -L "$soft" ]]; then
    if command -v realpath 2>&1 >/dev/null; then
      real=$(realpath "$soft")
      if ! echo $real | grep "Config" 2>&1 >/dev/null; then
        warning "RMing $soft..."
        rm -f "$soft" && return 0
      else
        # Already linked before.
        return 1
      fi
    else
      warning "Can not find 'realpath' command, exiting..." && exit 1
    fi
  fi
}

deploy () {
  # Loop through all keys in this dir array
  # Link the directory instead of linking every files
  for f in "${!dir[@]}"; do
    g="$target/${f/home\//}"
    any="$g/$(ls "$g" | tr '\n' ' ' | cut -d ' ' -f 1)"
    if [[ -n "$any" && -L $any ]]; then
      warning "Linked $g, rm for Dink"
      rm -fdr "$g"
    fi
    if [[ -e "$g" && ! -L "$g" ]]; then
    # If this file exists and is not a symbolic link
      action "$g exists"
      continue
    elif ! check_link "$g"; then
    # Check whther we have already linked this before.
      warning "Dinked $g"
      continue
    fi
    mkdir -p ${g%/*}
    info "Dinking $f"
    action "Dinking $f"
    # Otherwise linking to this repo.
    link home/$f $g
  done

  # Loop through all values in this files array
  for f in ${files[@]}; do
    if [[ "$f" =~ ^home/ ]]; then
    # If a file path starts with `home/` prefix.
      if check_skip home; then continue; fi
      g="$target/${f/home\//}"

    elif [[ "$f" =~ ^mac/ ]]; then
    # If a file path starts with `mac/` prefix.
      if [[ $(uname -s) != Darwin ]]; then continue; fi
      if check_skip mac; then continue; fi
      g="$target/${f/mac\//}"

    else
      # Skip other path patterns like etc/foo/bar here.
      continue
    fi

    if ! check_link "$g"; then
      warning "Linked $g"
    else 
      info "Copying $f"
    fi

    mkdir -p ${g%/*}
    if ! [[ -L "$g" ]]; then
      # If this file exists and its not a symbolic link.
      # Check whether its the same as the file we
      # about to link to.
      if [[ -f "$g" || "$f" -ot "$g" ]]; then
        if diff -q "$f" "$g"; then
          action "identical $g"
          continue
        else
          diff -u "$g" "$f" | less -FMX
          while :; do
            warning "Overwrite $g ?\n(y)es (n)skip (m)vim -d (q)uit [y/n/m/q]"
            read -rsn 1 option
            case $option in
              [ny])
                break;;
              m)
                vim -d "$g" "$f";;
              q)
                exit;;
              *)
                # While forever until getting a valid option.
                continue;;
            esac
          done
          if [[ $option == n ]]; then
            action "skipping $g"
            continue
          fi
        fi
      fi
      link "$f" "$g"
    fi
  done
}

main() {
  deploy
  do_ssh
  do_mkdir
  # fix_platform
  # do_git
  # load_service
}

main