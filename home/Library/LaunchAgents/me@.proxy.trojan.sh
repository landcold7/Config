#!/usr/bin/env bash
source ~/Util/log.sh

log info "starting trojan proxy service"

export PATH=~/bin:$PATH
pkill trojan
if ! trojan ~/.config/trojan-client.json ; then
  exit 1
fi
