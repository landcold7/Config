#!/usr/bin/env bash
set -x
set -e
ALGO="/Users/jche/Code/byteme"
BYTEDUMP="$ALGO/bytetools/byte-dump"
if [[ ! -d "$BYTEDUMP" ]]; then
  exit 1
fi
cd "$BYTEDUMP"
npm start