#!/usr/bin/env bash
set -e
source ~/Util/log.sh

log info "starting sysmte update service"

# Upgrade homebrew itself
log info "brew update"
brew update 2>&1

# Run Homebrew through the Brewfile
# Install or upgrade all packages
# TODO(zq7): complete this.
log info "brew bundle"
# brew bundle -v --file ~/core ~/user-app ~/graphic-app etc..

# Update mac app store
log info "softwareupdate -i -a"
softwareupdate -i -a 2>&1