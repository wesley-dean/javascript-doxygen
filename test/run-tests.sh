#!/usr/bin/env bash
## @file run-tests.sh
## @brief Runs the JavaScript filter regression fixtures and emits TAP.
## @details
## Each regression compares a filtered fixture with its golden expected output.
## The harness emits TAP version 13 so local and CI runs share one stable result
## format.

set -u

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
AWK_BIN=${AWK_BIN:-awk}
FILTER=${DOXYGEN_JAVASCRIPT_FILTER:-"$ROOT_DIR/doxygen-javascript.awk"}
TMP_DIR=$(mktemp -d)
failures=0

run_fixture() {
  local test_number=$1
  local fixture_name=$2
  local description=$3
  local fixture="$ROOT_DIR/test/fixtures/$fixture_name.js"
  local expected="$ROOT_DIR/test/expected/$fixture_name.js"
  local actual="$TMP_DIR/$fixture_name.js"

  if "$AWK_BIN" -f "$FILTER" -- "$fixture" >"$actual"; then
    if cmp -s "$expected" "$actual"; then
      printf 'ok %d - %s\n' "$test_number" "$description"
      return 0
    fi

    printf 'not ok %d - %s\n' "$test_number" "$description"
    printf '%s\n' '# filtered output differs from expected output'
    diff -u "$expected" "$actual" | sed 's/^/# /' || true
    failures=$((failures + 1))
    return 0
  fi

  printf 'not ok %d - %s\n' "$test_number" "$description"
  printf '%s\n' '# filter execution failed'
  failures=$((failures + 1))
}

trap 'rm -rf -- "$TMP_DIR"' EXIT HUP INT TERM

printf '%s\n' 'TAP version 13'
printf '%s\n' '1..5'

run_fixture 1 pass-through 'ordinary JavaScript passes through unchanged'
run_fixture 2 jsdoc-param-required 'required JSDoc parameter is translated'
run_fixture 3 jsdoc-param-optional 'defaulted optional JSDoc parameter is translated'
run_fixture 4 jsdoc-param-optional-no-default 'optional JSDoc parameter is translated'
run_fixture 5 jsdoc-param-property 'unsupported property parameter remains unchanged'

if ((failures > 0)); then
  exit 1
fi

exit 0
