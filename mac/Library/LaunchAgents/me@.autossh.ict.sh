#!/usr/bin/env bash
set -x
set -e

pkill autossh
if ! autossh -M 0 -f -T -N ict; then
  exit 1
fi
