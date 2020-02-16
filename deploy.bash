#!/usr/bin/env bash
set -e
# set -x

info() {
  printf "\e[1;36m$*\e[m\n"
}

action() {
  printf "\e[1;32m$*\e[m\n"
}

warning() {
  printf "\e[1;33m$*\e[m\n"
}

exclude="\
backup|\
.todo|\
.config|\
.zsh_history|\
Library/Rime|\
.zprezto\
"
# .tmux|\

files=($(git ls-files | egrep -v "$exclude"))

target=~
LN_OPT=-sf
[[ $(uname -s) == Linux ]] && LN_OPT=-sfr

# Declare a associative array, Newer bash has this feature.
# Link the whole directry instead of linking every file in this dir.
# i.e. ~/.tmux  --> ~/Config/home/.tmux
declare -A dir
# dir[.tmux]=1
dir[.todo]=1
dir[.config]=1
dir[Util]=1
dir[Library/Rime]=1
dir[.homebrew]=1
dir[.zprezto]=1

DEPLOY_DRY_RUN=$DEPLOY_DRY_RUN
if [[ -n "$DEPLOY_DRY_RUN" ]]; then info "!!! Deploy dry run for debugging"; fi

if ! command -v realpath >/dev/null 2>&1; then
  warning "Can not find `realpath` command, exiting..." && exit 1
fi

LINK() {
  if [[ -n "$DEPLOY_DRY_RUN" ]]; then
    action "DRY: " ln "$LN_OPT" "$PWD/$1" "$2"
  else
    ln "$LN_OPT" "$PWD/$1" "$2"
  fi
}

REMOVE() {
  warning "!!! REMOVE $1"
  if [[ -n "$DEPLOY_DRY_RUN" ]]; then
    action "DRY: " rm -fdrv "$1"
  else
    rm -fdr "$1"
  fi
}

MKDIR () {
  if [[ -n "$DEPLOY_DRY_RUN" ]]; then
    action "DRY: " mkdir -p "$1"
  else
    mkdir -p "$1"
  fi
}

do_ssh() {
  #cp -auT home/.ssh ~/.ssh
  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/*
}

do_mkdir() {
  MKDIR ~/{.history,tmp}
  MKDIR ~/.vimtmp/{backup,swap,undo}
  # MKDIR ~/Wallpapers ~/.local/opt
}

do_git() {
  # Updates all submodules contained in this repo.
  git submodule update --init --recursive
}

fix_platform() {
  # fix prezto, by default, this `✘` special sign casues ugly alignment problem.
  sed -i.bak 's/local show_return="✘ "/local show_return="x "/g' \
      ~/.zprezto/modules/prompt/functions/prompt_sorin_setup

  if [[ $(uname -s) != Darwin ]]; then return; fi

  # fix tmux-url plugin on osx
  sed -i.bak 's/xdg-open/open/g' \
    ~/.tmux/plugins/tmux-url-select/tmux-url-select.pl

  # fix system.update launchd service
  # (NOTE: may bring some security riskes into the system)
  sudo touch /etc/sudoers.d/sys-update
  echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/sys-update >/dev/null
}

launchd_service() {
  # Services that will run as user
  local agents=~/Library/LaunchAgents
  for agent in $(ls $agents/me@*.plist); do
    agent_name=$(basename $agent)
    if launchctl list | grep "$agent_name" >/dev/null 2>&1; then
      continue
    fi
    action "Launchd user ($agent)..."
    launchctl unload -w "$agent"
    launchctl load -w "$agent"
  done
}

systemd_service() {
  # Load all services for linux
  info "Service: not implemented" && return
}

load_service() {
  if [[ $(uname -s) == Darwin ]]; then
    launchd_service
  else
    systemd_service
  fi
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
  if [[ -n $skip ]]; then return 0; fi
  return 1
}

check_link() {
  # Check whether a soft link exists and doesn't point to Config repo
  if [[ -L "$1" ]]; then
    if ! realpath "$1" >/dev/null 2>&1; then
      return 0
    fi
    real=$(realpath "$1")
    if ! echo $real | grep "Config" 2>&1 >/dev/null; then
      REMOVE "$1"
      return 0
    else
      # Already linked before.
      return 1
    fi
  fi
}

deploy () {
  # Loop through all keys in this dir array
  # Link the directory instead of linking every files
  for f in "${!dir[@]}"; do
    g="$target/${f/home\//}"
    if [[ -e "$g" && ! -L "$g" ]]; then
      # If this directory exists and is not a symbolic link
      while : ; do
        warning "DLINK REMOVE $g ??? (y)es (s)show (q)uit [y/s/q]"
        read -rsn 1 option
        case $option in
          [y])
            REMOVE "$g";
            break;;
          s)
            ls -al "$g";
            continue;;
          q)
            exit;;
          *)
            # While forever until getting a valid option.
            continue;;
        esac
      done
    elif [[ -L "$g" ]]; then
      if diff -q "$target/$f" "$g" >/dev/null 2>&1; then
        action "identical $g"
        continue
      fi
    fi
    MKDIR ${g%/*}
    info "Dinking $f"
    LINK home/$f $g
  done

  # Loop through all values in this files array
  for f in ${files[@]}; do
    if [[ "$f" =~ ^home/ ]]; then
    # If a file path starts with `home/` prefix.
      if check_skip home; then continue; fi
      g="$target/${f/home\//}"
    else
      # Skip other path patterns like etc/foo/bar here.
      continue
    fi

    MKDIR ${g%/*}

    # Check whether its the same as the file we about to link to.
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
    info "Linking $f"
    LINK "$f" "$g"
  done
}

main() {
  deploy
  do_ssh
  do_mkdir
  fix_platform
  do_git
  load_service
}

main
