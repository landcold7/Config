#!/usr/bin/env bash

action() {
  printf "\e[1;32m$*\e[m\n"
}

action "\n\n\n====Update system $(date)===="

# Upgrade homebrew itself
action "\n› brew update"
brew update 2>&1

# Run Homebrew through the Brewfile
# Install or upgrade all packages
# TODO(zq7): complete this.
action "\n› brew bundle"
# brew bundle -v --file ~/core ~/user-app ~/graphic-app etc..

# Update mac app store
action "\n› softwareupdate -i -a"
softwareupdate -i -a 2>&1