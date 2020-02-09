#!/usr/bin/env bash
source ~/Util/log.sh

log info "starting autossh service"

pkill autossh 
if ! autossh -M 0 -f -T -N ict; then
  exit 1
fi
