#!/usr/bin/env bash
set -e

source ~/Util/log.sh
log info "starting bytedump service"

ALGO="/Users/jche/dev/byteme"
BYTEDUMP="$ALGO/bytetools/byte-dump"
if [[ ! -d "$BYTEDUMP" ]]; then
  exit 1
fi
cd "$BYTEDUMP"
npm start