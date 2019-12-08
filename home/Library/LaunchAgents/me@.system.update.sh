#!/usr/bin/env bash

### launchcd usage examples:
## start a already loeaded service
# launchctl start me@.system.update.plist
## load a service
# launchctl load -w me@.system.update.plist

source ~/Util/log.sh

log info "starting sysmte update service"

# Update mac app store
log info "softwareupdate -i -a"
softwareupdate -i -a

# Upgrade homebrew itself
log info "brew update"
brew update

# Install or upgrade all packages
log info "brew bundle dev"
brew bundle -v --file=~/.homebrew/dev

log info "brew bundle app"
brew bundle -v --file=~/.homebrew/app

log info "brew cleanup"
brew cleanup