# AGENTS.md

## Repository Purpose

`javascript-doxygen` provides a documentation-led Doxygen input filter for
JavaScript.  Maintained JavaScript should remain idiomatic JavaScript; translation
belongs at the Doxygen boundary rather than in a second maintained documentation
dialect.

The maintained filter is `doxygen-javascript.awk`.

The current bootstrap milestone implements pass-through only.  Do not claim JSDoc
translation, JavaScript semantic analysis, Doxygen integration, generated consumer
artifacts, or release support until executable evidence and governing decisions
exist.

## Governing Documentation

Before changing the repository, review `README.md`, this file,
`doc/documentation-standard.md`, the applicable files under `doc/standards/`,
every ADR in `doc/adr/*.md`, and `doc/decisions.md`.

Accepted ADRs are governance.  Consequential parser, interface, portability,
compatibility, documentation-publication, or release changes require an ADR unless
existing governance already covers the decision.

Files under `doc/standards/` are governing project requirements when applicable.
General and cross-cutting standards apply where relevant; language-specific
standards apply only to maintained content in that language.  Presence in the
complete released snapshot does not by itself make a standard applicable.
Content beneath `doc/standards/examples/` is illustrative unless a governing
standard explicitly says otherwise.

Accepted repository-specific ADRs and explicit local policy may refine or
supersede imported standards.  Do not silently deviate from an applicable
standard.  Do not edit imported standards locally; project-specific exceptions
belong in repository governance.  `.codingstandardrc` records the concrete
upstream release and archive digest for the managed snapshot.

## Documentation Standards

No JavaScript documentation standard has been adopted by this repository yet.
`doc/documentation-standard.md` records that status.  Until a JavaScript standard
is adopted, do not infer a normative JSDoc subset from implementation ideas or
copied Python documentation.

Maintained AWK source follows
`doc/standards/awk/documentation-standard.md`, whose canonical upstream is
`wesley-dean/coding_standards/standards/awk/documentation-standard.md`.

## Architecture and Scope

ADR-012 establishes the current JavaScript bootstrap boundary.

The filter currently passes newline-terminated JavaScript source records through
without documentation transformation.  This is an executable bootstrap contract,
not evidence of JSDoc compatibility.

Future JSDoc translation should remain narrow and evidence-driven.  Prefer visible
unsupported syntax to speculative semantic claims.  Do not add JavaScript parsing,
type inference, inferred behavior, or broad JSDoc semantics without explicit
governance and focused tests.

Copied Python implementation, tests, ADRs, and workflow history may remain during
migration as reference material.  They are not current JavaScript capability
claims where ADR-012 supersedes their Python-specific contracts.

## Portability and Testing

Portable AWK is the compatibility floor.  Production filter source must run under
at least `mawk` and GNU awk.

Behavior-focused JavaScript fixtures live under `test/fixtures/`.  Golden filtered
output lives under `test/expected/`.  `test/run-tests.sh` emits TAP version 13.

Use:

```sh
make test AWK_BIN=mawk
make test AWK_BIN=gawk
```

The current suite proves only representative pass-through behavior.  Add a focused
fixture and expected output when adding each new supported translation behavior.
Tests should protect externally observable behavior rather than internal helper
structure.

## Deferred Infrastructure

Automatic Python-specific documentation canaries and semantic-version release
publication are deferred under ADR-012.  Do not add no-op compatibility targets
merely to make copied workflows succeed.

Doxygen integration, generated consumer artifacts, checksums, documentation
publication, and release canaries should be re-enabled only after JavaScript-
specific contracts exist and are tested.

## Engineering Approach

Keep changes surgical and reviewable.  Accuracy is more important than apparent
completeness.  Distinguish implemented behavior from planned behavior, state
uncertainty explicitly, and do not widen the parser or documentation boundary
without governance and focused executable evidence.
