#!/usr/bin/env bash
source ~/Util/log.sh

log info "starting autossh service"

pkill trojan
if ! trojan .config/trojan-client.json ; then
  exit 1
fi
