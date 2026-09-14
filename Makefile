# Canonical validation and self-documentation entry points for javascript-doxygen.

SHELL := /bin/sh
.SHELLFLAGS := -eu -c

AWK_BIN ?= awk
SOURCE_FILTER := doxygen-javascript.awk
DOXYGEN_CONSUMER_CONFIG := doxygen-javascript.conf
INTEGRATION_CONFIG := test/doxygen/Doxyfile
INTEGRATION_OUT := test/doxygen/out
DOXYGEN_JAVASCRIPT_FILTER ?= $(SOURCE_FILTER)

VENDOR_DIR := vendor
DOCS_MANIFEST := dependencies-docs.txt
BASHDEPS := $(VENDOR_DIR)/bashdeps.bash
BASHDEPS_VERSION := 0.0.10
BASHDEPS_URL := https://github.com/wesley-dean/bashdeps/releases/download/v$(BASHDEPS_VERSION)/bashdeps.bash
BASHDEPS_SHA256 := acbe79d39ab8cbbf906bd864d410ba7a223ba6f09501c02a409b8d3aa8740462
VENDOR_AWK_FILTER := $(VENDOR_DIR)/doxygen-awk.awk
VENDOR_BASH_FILTER := $(VENDOR_DIR)/doxygen-bash.awk
ADRCTL := $(VENDOR_DIR)/adrctl.bash
ADR_DIR := doc/adr
ADR_INDEX_FILE := $(ADR_DIR)/README.md
ADR_INDEX_INTRO := $(ADR_DIR)/README.intro.md
ADR_INDEX_OUTRO := $(ADR_DIR)/README.outro.md
REFERENCE_DOC_DIR := doc/reference
AWK_DOXYGEN_FILTER ?= $(VENDOR_AWK_FILTER)
BASH_DOXYGEN_FILTER ?= $(VENDOR_BASH_FILTER)

.PHONY: adr-index clean deps-docs deps-docs-check distclean docs docs-canary docs-clean integration-clean test test-doxygen test-source verify-bashdeps FORCE

test: test-source

## Run the TAP regression suite against the maintained JavaScript filter.
test-source:
	@test -f "$(SOURCE_FILTER)" || { printf '%s\n' 'Missing JavaScript Doxygen filter' >&2; exit 1; }
	DOXYGEN_JAVASCRIPT_FILTER="$(abspath $(SOURCE_FILTER))" AWK_BIN="$(AWK_BIN)" bash ./test/run-tests.sh

## Exercise governed JavaScript fixtures through Doxygen with the selected filter.
test-doxygen:
	@test -f "$(DOXYGEN_JAVASCRIPT_FILTER)" || { printf '%s\n' 'Missing JavaScript Doxygen filter' >&2; exit 1; }
	@test -f "$(DOXYGEN_CONSUMER_CONFIG)" || { printf '%s\n' 'Missing JavaScript Doxygen consumer configuration' >&2; exit 1; }
	@grep -Fxq 'ALIASES += jsyields="@par Yields^^"' "$(DOXYGEN_CONSUMER_CONFIG)" || { printf '%s\n' 'Missing governed jsyields alias' >&2; exit 1; }
	@command -v doxygen >/dev/null 2>&1 || { printf '%s\n' 'doxygen is required for make test-doxygen' >&2; exit 1; }
	$(MAKE) --no-print-directory integration-clean
	AWK_BIN="$(AWK_BIN)" DOXYGEN_JAVASCRIPT_FILTER="$(abspath $(DOXYGEN_JAVASCRIPT_FILTER))" doxygen "$(INTEGRATION_CONFIG)"
	grep -R -q '<parameterlist kind="param">' "$(INTEGRATION_OUT)/xml"
	grep -R -q '<parametername>value</parametername>' "$(INTEGRATION_OUT)/xml"
	grep -R -q '<parametername>strict</parametername>' "$(INTEGRATION_OUT)/xml"
	grep -R -q 'Value to normalize' "$(INTEGRATION_OUT)/xml"
	grep -R -q 'Optional.' "$(INTEGRATION_OUT)/xml"
	grep -R -q 'Default: true.' "$(INTEGRATION_OUT)/xml"
	grep -R -q '<simplesect kind="return">' "$(INTEGRATION_OUT)/xml"
	grep -R -q 'The canonical normalized value' "$(INTEGRATION_OUT)/xml"
	grep -R -q 'Type: string.' "$(INTEGRATION_OUT)/xml"
	grep -R -q '<parameterlist kind="exception">' "$(INTEGRATION_OUT)/xml"
	grep -R -q '<parametername>TypeError</parametername>' "$(INTEGRATION_OUT)/xml"
	grep -R -q 'not a string' "$(INTEGRATION_OUT)/xml"
	grep -R -q '<title>Yields</title>' "$(INTEGRATION_OUT)/xml"
	grep -R -q 'Type: Record.' "$(INTEGRATION_OUT)/xml"
	grep -R -q 'Validated records in source order.' "$(INTEGRATION_OUT)/xml"
	grep -R -q 'validatedRecords' "$(INTEGRATION_OUT)/xml"
	grep -R -q 'line="6"' "$(INTEGRATION_OUT)/xml"

FORCE:

## Bootstrap only bashdeps directly, verifying pinned bytes before execution.
$(BASHDEPS): FORCE
	@mkdir -p "$(VENDOR_DIR)"
	@verify_hash() { \
		path=$$1; \
		if command -v sha256sum >/dev/null 2>&1; then \
			printf '%s  %s\n' "$(BASHDEPS_SHA256)" "$$path" | sha256sum -c - >/dev/null 2>&1; \
		elif command -v shasum >/dev/null 2>&1; then \
			[ "$$(shasum -a 256 "$$path" | awk '{print $$1}')" = "$(BASHDEPS_SHA256)" ]; \
		else \
			return 2; \
		fi; \
	}; \
	if [ -f "$@" ] && verify_hash "$@"; then chmod 0755 "$@"; exit 0; fi; \
	tmp="$@.tmp"; trap 'rm -f "$$tmp"' EXIT; \
	if command -v curl >/dev/null 2>&1; then \
		curl -fsSL "$(BASHDEPS_URL)" -o "$$tmp"; \
	elif command -v wget >/dev/null 2>&1; then \
		wget -qO "$$tmp" "$(BASHDEPS_URL)"; \
	else \
		printf '%s\n' 'curl or wget is required to bootstrap bashdeps.bash' >&2; exit 1; \
	fi; \
	verify_hash "$$tmp" || { printf '%s\n' 'Downloaded bashdeps.bash does not match the committed SHA-256 digest' >&2; exit 1; }; \
	chmod 0755 "$$tmp"; mv "$$tmp" "$@"; trap - EXIT

## Verify the pinned bashdeps bootstrap without network access or repair.
verify-bashdeps:
	@test -x "$(BASHDEPS)" || { printf '%s\n' 'Missing or non-executable vendor/bashdeps.bash; run make deps-docs' >&2; exit 1; }
	@if command -v sha256sum >/dev/null 2>&1; then \
		printf '%s  %s\n' "$(BASHDEPS_SHA256)" "$(BASHDEPS)" | sha256sum -c - >/dev/null 2>&1 || { printf '%s\n' 'bashdeps.bash digest mismatch; run make deps-docs' >&2; exit 1; }; \
	elif command -v shasum >/dev/null 2>&1; then \
		[ "$$(shasum -a 256 "$(BASHDEPS)" | awk '{print $$1}')" = "$(BASHDEPS_SHA256)" ] || { printf '%s\n' 'bashdeps.bash digest mismatch; run make deps-docs' >&2; exit 1; }; \
	else \
		printf '%s\n' 'No SHA-256 verification command is available for bashdeps.bash' >&2; exit 1; \
	fi

## Synchronize documentation-only dependencies; this target may use the network.
deps-docs: $(BASHDEPS) $(DOCS_MANIFEST)
	$(MAKE) --no-print-directory verify-bashdeps
	"$(BASHDEPS)" sync "$(DOCS_MANIFEST)"

## Verify prepared documentation dependencies without network access or repair.
deps-docs-check: verify-bashdeps $(DOCS_MANIFEST)
	"$(BASHDEPS)" verify "$(DOCS_MANIFEST)"

## Generate the ephemeral ADR landing page from maintained framing and ADR source.
adr-index:
	@test -r "$(ADRCTL)" || { printf '%s\n' 'Missing documentation dependency vendor/adrctl.bash; run make deps-docs first' >&2; exit 1; }
	@test -r "$(ADR_INDEX_INTRO)" || { printf '%s\n' 'Missing ADR landing-page introduction' >&2; exit 1; }
	@test -r "$(ADR_INDEX_OUTRO)" || { printf '%s\n' 'Missing ADR landing-page conclusion' >&2; exit 1; }
	@tmp="$(ADR_INDEX_FILE).tmp"; \
	trap 'rm -f "$$tmp"' EXIT; \
	bash "$(ADRCTL)" generate toc -i "$(ADR_INDEX_INTRO)" -o "$(ADR_INDEX_OUTRO)" >"$$tmp"; \
	mv "$$tmp" "$(ADR_INDEX_FILE)"; \
	trap - EXIT

## Generate stable project reference documentation with pinned released filters.
docs: deps-docs-check
	$(MAKE) --no-print-directory docs-canary \
		AWK_DOXYGEN_FILTER="$(VENDOR_AWK_FILTER)" \
		BASH_DOXYGEN_FILTER="$(VENDOR_BASH_FILTER)"

## Generate project reference documentation with explicitly selected filter paths.
docs-canary:
	@test -f "$(AWK_DOXYGEN_FILTER)" || { printf '%s\n' 'Missing AWK Doxygen filter' >&2; exit 1; }
	@test -f "$(BASH_DOXYGEN_FILTER)" || { printf '%s\n' 'Missing Bash Doxygen filter' >&2; exit 1; }
	chmod 0755 "$(AWK_DOXYGEN_FILTER)" "$(BASH_DOXYGEN_FILTER)"
	"$(AWK_BIN)" -f "$(AWK_DOXYGEN_FILTER)" -- --strict --compact "$(SOURCE_FILTER)" >/dev/null
	"$(AWK_BIN)" -f "$(BASH_DOXYGEN_FILTER)" -- --strict --compact ./test/run-tests.sh >/dev/null
	$(MAKE) --no-print-directory adr-index
	$(MAKE) --no-print-directory docs-clean
	AWK_DOXYGEN_FILTER="$(abspath $(AWK_DOXYGEN_FILTER))" \
	BASH_DOXYGEN_FILTER="$(abspath $(BASH_DOXYGEN_FILTER))" \
		doxygen Doxyfile

## Remove generated JavaScript/Doxygen integration output.
integration-clean:
	rm -rf "$(INTEGRATION_OUT)"

## Remove generated project reference documentation.
docs-clean:
	rm -rf "$(REFERENCE_DOC_DIR)"

clean: integration-clean docs-clean

## Remove generated reference, ADR-navigation, and documentation dependency state.
distclean: clean
	rm -rf "$(VENDOR_DIR)"
	rm -f "$(ADR_INDEX_FILE)"
