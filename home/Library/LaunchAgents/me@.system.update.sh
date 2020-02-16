#!/usr/bin/env bash
set -e

### launchcd usage examples:

## start a already loaded service
# launchctl start me@.system.update.plist

## load a service
# launchctl load -w me@.system.update.plist

source ~/Util/log.sh

log info "starting sysmte update service"

# Update mac app store
log info "softwareupdate -i -a"
softwareupdate -i -a --restart

# Upgrade homebrew itself
log info "brew update"
brew update

log info "brew upgrade"
brew upgrade

log info "brew cask upgrade"
brew cask upgrade --greedy
# brew cask upgrade
# brew cask outdated | xargs brew reinstall

# Install or upgrade all packages
log info "brew bundle dev"
brew bundle -v --file=~/.homebrew/dev

# log info "brew bundle app"
# brew bundle -v --file=~/.homebrew/app

log info "brew cleanup"
brew cleanup

# while read -r line; do
#   if [[ $line =~ ^cask  ]]; then
#     app=$(echo $line | cut -d ' ' -f 2 | tr -d "'")
#     log info "brew cask install $app --force"
#     brew cask install $app
#   fi
# done < ~/.homebrew/app
