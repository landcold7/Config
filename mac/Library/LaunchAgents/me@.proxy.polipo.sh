#!/usr/bin/env bash

source ~/Util/log.sh

log info "starting polipo service"

# Creates a http proxy
pkill polipo
polipo -c ~/.config/polipo.conf 
