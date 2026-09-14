# Canonical bootstrap validation entry points for javascript-doxygen.

SHELL := /bin/sh
.SHELLFLAGS := -eu -c

AWK_BIN ?= awk
SOURCE_FILTER := doxygen-javascript.awk

.PHONY: test test-source

test: test-source

## Run the TAP regression suite against the maintained JavaScript filter.
test-source:
	@test -f "$(SOURCE_FILTER)" || { printf '%s\n' 'Missing JavaScript Doxygen filter' >&2; exit 1; }
	DOXYGEN_JAVASCRIPT_FILTER="$(abspath $(SOURCE_FILTER))" AWK_BIN="$(AWK_BIN)" bash ./test/run-tests.sh
