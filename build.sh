#!/usr/bin/env bash
# JujuDaHood bundler. SP0: monolithic passthrough (src -> dist).
# Future SP1/SP2: concatenate feature modules onto the base here.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
cp "$HERE/src/juju.lua" "$HERE/dist/JujuDaHood.lua"
echo "built dist/JujuDaHood.lua ($(wc -l < "$HERE/dist/JujuDaHood.lua")L)"
