# AGENTS.md

## Repository Purpose

`javascript-doxygen` provides a documentation-led Doxygen input filter for
JavaScript.  Maintained JavaScript should remain idiomatic JavaScript; translation
belongs at the Doxygen boundary rather than in a second maintained documentation
dialect.

The maintained filter is `doxygen-javascript.awk`.

The current implementation translates only the accepted simple-parameter JSDoc
forms governed by ADR-013 and ADR-014, canonical typed `@returns` records governed
by ADR-016, and canonical typed-and-described `@throws` records governed by
ADR-017.  Unsupported JSDoc constructs remain visible unchanged.  Do not claim
broader JSDoc translation, JavaScript semantic analysis, JavaScript/Doxygen
integration, generated consumer artifacts, or release support until executable
evidence and governing decisions exist.

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

Maintained JavaScript documentation follows
`doc/standards/javascript/documentation-standard.md`, whose canonical upstream is
`wesley-dean/coding_standards/standards/javascript/documentation-standard.md`.
JSDoc is therefore the maintained source documentation language for JavaScript in
this repository.

The shared standard defines valid maintained-source forms.  Filter support is a
separate, narrower contract governed by this repository's accepted ADRs and
regression tests.  Do not infer that `doxygen-javascript.awk` translates a JSDoc
construct merely because the shared standard permits that construct.

Maintained AWK source follows
`doc/standards/awk/documentation-standard.md`, whose canonical upstream is
`wesley-dean/coding_standards/standards/awk/documentation-standard.md`.

## Architecture and Scope

ADR-012 establishes the JavaScript filter and TAP regression boundary.  ADR-013
adds canonical required-parameter translation.  ADR-014 adds canonical optional
parameters with and without compact documented defaults.  ADR-016 adds canonical
typed `@returns` translation while preserving the `@returns` command itself.
ADR-017 adds canonical typed-and-described `@throws` translation by removing the
JSDoc type braces and preserving Doxygen's native exception-object position.

Supported parameter names remain simple JavaScript identifiers.  The filter keeps
type expressions and supported optional defaults as textual documentation data
rather than interpreting them as JavaScript semantics.  Compact defaults must be
non-empty and contain neither whitespace nor `]` in the current grammar.

Canonical typed returns use `@returns {Type} Description.` and are emitted as
`@returns Description. Type: Type.`.  Canonical typed exceptions use
`@throws {Type} Description.` with a compact non-whitespace exception type and are
emitted as `@throws Type Description.`.

The singular JSDoc synonym `@return`, untyped returns, typed returns without
descriptions, description-only `@throws`, type-only `@throws`, throws types with
whitespace, continuation records, `@yields`, dotted properties, optional dotted
properties, rest parameters, destructured parameter documentation, and one-line
JSDoc blocks remain unsupported and should pass through visibly.

Future JSDoc translation should remain narrow and evidence-driven.  Prefer visible
unsupported syntax to speculative semantic claims.  Do not add JavaScript parsing,
type inference, inferred behavior, or broad JSDoc semantics without explicit
governance and focused tests.

Copied Python implementation, tests, ADRs, and workflow history may remain during
migration as reference material.  They are not current JavaScript capability
claims where ADR-012 and later JavaScript-specific decisions supersede their
Python-specific contracts.

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

The current suite proves ordinary source pass-through; required-parameter
translation; optional-parameter translation with and without compact documented
defaults; visible pass-through of unsupported dotted property notation; canonical
typed `@returns` translation; visible pass-through of singular `@return`;
canonical typed-and-described `@throws` translation; and visible pass-through of
description-only and type-only throws forms.  Add a focused fixture and expected
output when adding each new supported translation behavior.  Tests should protect
externally observable behavior rather than internal helper structure.

## Project Self-Documentation

ADR-015 restores project self-documentation independently of JavaScript/Doxygen
integration.  `doxygen-javascript.awk` is AWK source and is documented with the
pinned released `awk-doxygen` filter.  `test/run-tests.sh` is Bash source and is
documented with the pinned released `bash-doxygen` filter.

Use:

```sh
make deps-docs
make deps-docs-check
make docs AWK_BIN=mawk
```

The documentation canary SHALL exercise this path on pull requests.  Pages SHALL
publish the generated `doc/reference/` tree after pushes to `main`.  Generated
`vendor/`, `doc/reference/`, and `doc/adr/README.md` state remains untracked.

Do not treat successful project self-documentation as evidence that JavaScript
source has been exercised through Doxygen with `doxygen-javascript.awk`.

## Deferred Infrastructure

JavaScript/Doxygen integration testing, generated consumer artifacts, checksums,
semantic-version release publication, and release-artifact canaries remain
deferred under ADR-012 and ADR-015.  Do not add no-op compatibility targets merely
to make copied workflows succeed.

## Engineering Approach

Keep changes surgical and reviewable.  Accuracy is more important than apparent
completeness.  Distinguish implemented behavior from planned behavior, state
uncertainty explicitly, and do not widen the parser or documentation boundary
without governance and focused executable evidence.
