#!/usr/bin/env bash
## @file run-tests.sh
## @brief Runs the JavaScript filter regression fixtures and emits TAP.
## @details
## The harness compares each filtered fixture with its golden expected output.
## Milestone 1 contains one pass-through fixture so the filter, fixture layout,
## and TAP contract exist before JSDoc translations are introduced.

set -u

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
AWK_BIN=${AWK_BIN:-awk}
FILTER=${DOXYGEN_JAVASCRIPT_FILTER:-"$ROOT_DIR/doxygen-javascript.awk"}
FIXTURE="$ROOT_DIR/test/fixtures/pass-through.js"
EXPECTED="$ROOT_DIR/test/expected/pass-through.js"
TMP_DIR=$(mktemp -d)
ACTUAL="$TMP_DIR/pass-through.js"

cleanup() {
  rm -rf -- "$TMP_DIR"
}

trap cleanup EXIT HUP INT TERM

printf '%s\n' 'TAP version 13'
printf '%s\n' '1..1'

if "$AWK_BIN" -f "$FILTER" -- "$FIXTURE" >"$ACTUAL"; then
  if cmp -s "$EXPECTED" "$ACTUAL"; then
    printf '%s\n' 'ok 1 - ordinary JavaScript passes through unchanged'
    exit 0
  fi

  printf '%s\n' 'not ok 1 - ordinary JavaScript passes through unchanged'
  printf '%s\n' '# filtered output differs from expected output'
  diff -u "$EXPECTED" "$ACTUAL" | sed 's/^/# /' || true
  exit 1
fi

printf '%s\n' 'not ok 1 - ordinary JavaScript passes through unchanged'
printf '%s\n' '# filter execution failed'
exit 1
