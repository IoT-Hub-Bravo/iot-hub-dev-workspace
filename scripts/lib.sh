#!/usr/bin/env bash

# context for logging (e.g. init, up)
SCRIPT_CONTEXT="${SCRIPT_CONTEXT:-script}"

log() {
  printf "[%s] %s\n" "$SCRIPT_CONTEXT" "$1"
}

warn() {
  printf "[%s][warn] %s\n" "$SCRIPT_CONTEXT" "$1" >&2
}

fail() {
  printf "[%s][error] %s\n" "$SCRIPT_CONTEXT" "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

require_file() {
  [ -f "$1" ] || fail "File not found: $1"
}

require_dir() {
  [ -d "$1" ] || fail "Directory not found: $1"
}
