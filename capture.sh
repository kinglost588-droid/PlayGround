#!/usr/bin/env bash
set -euo pipefail
time -p cd "$(dirname "$0")"
/usr/bin/time -p pwd
RUNTIME_FALLBACK="/home/runner/work/_temp/omgithub-runtime"
RUNTIME_DIR="${RUNTIME_DIR:-$RUNTIME_FALLBACK}"
export RUNTIME_DIR
/usr/bin/time -p test -n "${CAPTURE_URL:-}"
/usr/bin/time -p test -n "${CAPTURE_DIR:-}"
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
/usr/bin/time -p test -f "$RUNTIME_DIR/scripts/default-capture.mjs"
/usr/bin/time -p node "$RUNTIME_DIR/scripts/default-capture.mjs"
/usr/bin/time -p test -f "$CAPTURE_DIR/final-desktop.png"
/usr/bin/time -p test -f "$CAPTURE_DIR/final-mobile.png"
/usr/bin/time -p ls -l "$CAPTURE_DIR"
