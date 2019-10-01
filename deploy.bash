#!/usr/bin/env bash
set -e

exclude="\
backup|\
proxy.pac.coffee|\
weechat\
"

files=($(git ls-files | egrep -v "$exclude"))

target=~
LN_OPT=-sf
[[ $(uname -s) == Linux ]] && LN_OPT=-sfr

# Declare a associative array.
# Newer bash has this feature.
declare -A dir
# dir[.vim]=1
# dir[.emacs.d/private/+my]=1
# dir[.config/doom]=1

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

fix_prezto() {
  # By default, this `✘` special sign casues ugly alignment problem.
  sed -i.bak 's/local show_return="✘ "/local show_return="x "/g' \
      ~/.zprezto/modules/prompt/functions/prompt_sorin_setup
}

# Loop through all keys in this dir array
for f in "${!dir[@]}"; do
  g="$target/${f/home\//}"
  mkdir -p ${g%/*}
  if [[ -e "$g" && ! -L "$g" ]]; then
  # If this file exists and its not a symbolic link
    action "$g exists"
    continue
  fi
  # Otherwise linking to this repo.
  link home/$f $g
done

# Loop through all values in this files array
for f in ${files[@]}; do
  if [[ "$f" =~ ^home/ ]]; then
    # If a file path starts with `home/` prefix.
    ff=${f/home\//}
    skip=
    while : ; do
      # Try every level of the path to see whether
      # its already been processed before.
      [[ ${dir[$ff]+_} ]] && skip=1
      [[ $ff =~ / ]] || break
      ff=${ff%/*}
    done
    [[ -n $skip ]] && continue
  else
    # Skip other path patterns like etc/foo/bar here.
    continue
  fi

  info "Copying $f"
  g="$target/${f/home\//}"
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

do_ssh
do_mkdir
do_git
fix_prezto
