# AGENTS.md

## Repository Purpose

`python-doxygen` provides a documentation-led Doxygen input filter for Python.
Maintained Python remains idiomatic Python; the filter translates supported
docstring syntax only at the Doxygen boundary.

The maintained filter is `doxygen-python.awk`.  It is a documentation translator,
not a complete Python parser.  Capability claims must match tests and accepted
ADRs.

## Governing Documentation

Before changing the repository, review `README.md`, this file,
`doc/documentation-standard.md`, the applicable files under `doc/standards/`,
every ADR in `doc/adr/*.md`, and `doc/decisions.md`.

Accepted ADRs are governance.  Consequential parser, interface, portability,
compatibility, documentation-publication, or release changes require an ADR
unless existing governance already covers the decision.

Files under `doc/standards/` are governing project requirements, not suggestions,
when they apply to maintained content.  General and cross-cutting standards apply
where relevant; language-specific standards apply to maintained content in that
language.  Presence in the complete released snapshot does not by itself make a
standard applicable.  Content under `doc/standards/examples/` is illustrative and
non-normative unless a governing standard explicitly says otherwise.

Accepted repository-specific ADRs and explicit local policy may refine or
supersede imported standards.  Do not silently deviate from an applicable
standard.  Do not edit imported standards locally; project-specific exceptions
belong in repository governance.  `.codingstandardrc` records the concrete
upstream release and archive digest for the managed snapshot.

## Documentation Standards

The adopted Python documentation standard is materialized at
`doc/standards/python/documentation-standard.md`; its canonical upstream is
`wesley-dean/coding_standards/standards/python/documentation-standard.md`.
`doc/documentation-standard.md` records this repository's adoption point.  Do not
independently rewrite or weaken the imported Python contract here.

Maintained AWK source follows
`doc/standards/awk/documentation-standard.md`, whose canonical upstream is
`wesley-dean/coding_standards/standards/awk/documentation-standard.md`.  The older
`doc/awk-documentation-standard.md` path remains from the copied baseline and is
not an independently mutable standards authority.  Documentation changes to
`doxygen-python.awk` must preserve executable behavior unless the change is
separately governed and tested as a behavior change.

## Architecture and Scope

Preserve Python-native documentation as the human- and linter-facing source of
truth.  Do not require Doxygen-specific Python docstrings or duplicate Doxygen
comment blocks.  ADR-002 establishes the source-preserving Doxygen representation
based on an executable integration experiment.

The filter is intentionally narrow.  Prefer false negatives and visible
unsupported syntax to speculative semantic claims.  Do not add signature
validation, type inference, inferred behavior, broad decorator semantics, or
complete Python parsing without explicit governance.

`:yields:` is outside milestone 1 under ADR-003.

## Portability and Testing

Portable AWK is the compatibility floor.  Production filter source must run under
at least `mawk` and GNU awk.

Behavior-focused fixtures live under `tests/python/`.  Fixtures protect public
behavior, not helper structure.  The same semantic suite must run against
maintained `doxygen-python.awk` and generated `dist/doxygen-python.awk`.

Use `make test AWK_BIN=mawk` and `make test AWK_BIN=gawk`.  Preserve source-line
correspondence where practical, and pass ordinary Python source outside translated
docstrings through unchanged.  `make test-doxygen` exercises the selected Python
filter against the focused Python/Doxygen integration fixture.

## Documentation Tooling

Project reference documentation describes this repository's maintained AWK,
Bash, Markdown, and ADR sources.  It is distinct from the Python-filter integration
test.

Documentation-only dependencies are pinned in `dependencies-docs.txt` and are
materialized beneath `vendor/` by the SHA-256-pinned `bashdeps` bootstrap.  The
set includes released `awk-doxygen`, released `bash-doxygen`, and released
`adrctl`.  `make deps-docs` may use the network; `make deps-docs-check`,
`make adr-index`, and `make docs` consume prepared state without silently
repairing or advancing dependency pins.

Generated `doc/adr/README.md`, `doc/reference/`, and `vendor/` state is disposable
and must remain ignored by Git.

## Build and Release

The maintained source and consumer outputs are `doxygen-python.awk`,
`dist/doxygen-python.awk`, and `dist/doxygen-python.awk.sha256`.  `make build` is
the canonical artifact build.  Build provenance is comments only and must not add
executable AWK state.

Semantic-version releases are a downstream dependency interface.  The versioning
workflow must validate maintained and generated bytes, verify the checksum, and
publish both `doxygen-python.awk` and `doxygen-python.awk.sha256` as release
assets.  Other repositories may pin those exact release assets with `bashdeps`,
so a version tag without the governed assets is an incomplete release.

Exact published release bytes must be checksum-verified and exercised through the
Python/Doxygen integration fixture.  Do not substitute a tag checkout for this
asset-level validation.

## Engineering Approach

Keep changes surgical and reviewable.  Accuracy is more important than apparent
completeness.  Distinguish implemented behavior from planned behavior, state
uncertainty explicitly, and do not widen the parser boundary without governance
and focused fixtures.
