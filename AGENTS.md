# AGENTS.md

## Repository Purpose

`javascript-doxygen` provides a documentation-led Doxygen input filter for
JavaScript.  Maintained JavaScript should remain idiomatic JavaScript; translation
belongs at the Doxygen boundary rather than in a second maintained documentation
dialect.

The maintained filter is `doxygen-javascript.awk`.

The current implementation translates only the accepted simple-parameter JSDoc
forms governed by ADR-013 and ADR-014, canonical typed `@returns` records governed
by ADR-016, canonical typed-and-described `@throws` records governed by ADR-017,
and canonical typed `@yields` records governed by ADR-019.  ADR-018 exercises
governed forms through Doxygen's JavaScript parser, and ADR-020 establishes
native-compatible pass-through for proven `@deprecated` and `@see` forms.
Unsupported JSDoc constructs remain visible unchanged.  Do not claim broader
JSDoc translation, native compatibility, JavaScript semantic analysis, generated
consumer artifacts, or release support until executable evidence and governing
decisions exist.

## Governing Documentation

Before changing the repository, review `README.md`, this file,
`doc/documentation-standard.md`, the applicable files under `doc/standards/`,
every ADR in `doc/adr/*.md`, and `doc/decisions.md`.

Accepted ADRs are governance.  Consequential parser, interface, portability,
compatibility, documentation-publication, integration, consumer-configuration, or
release changes require an ADR unless existing governance already covers the
decision.

Files under `doc/standards/` are governing project requirements when applicable.
General and cross-cutting standards apply where relevant; language-specific
standards apply only to maintained content in that language.  Presence in the
complete released snapshot does not by itself make a standard applicable.  Content
beneath `doc/standards/examples/` is illustrative unless a governing standard
explicitly says otherwise.

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
regression tests.  Do not infer that `doxygen-javascript.awk` translates or
natively supports a JSDoc construct merely because the shared standard permits
that construct.

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
ADR-018 establishes downstream JavaScript/Doxygen integration evidence for those
already-governed forms.  ADR-019 adds canonical typed `@yields` translation through
a line-preserving generated `@jsyields` command plus a required Doxygen alias.
ADR-020 establishes that canonical JSDoc records that are already semantically and
syntactically compatible with Doxygen should pass through unchanged when focused
TAP and integration evidence prove that compatibility.

Supported parameter names remain simple JavaScript identifiers.  The filter keeps
type expressions and supported optional defaults as textual documentation data
rather than interpreting them as JavaScript semantics.  Compact defaults must be
non-empty and contain neither whitespace nor `]` in the current grammar.

Canonical typed returns use `@returns {Type} Description.` and are emitted as
`@returns Description. Type: Type.`.  Canonical typed exceptions use
`@throws {Type} Description.` with a compact non-whitespace exception type and are
emitted as `@throws Type Description.`.  Canonical typed yields use
`@yields {Type} Description.` and are emitted as
`@jsyields Type: Type. Description.`.

`@jsyields` is generated Doxygen-facing syntax only.  Maintainers SHALL continue
to write JSDoc `@yields`.  Consumers that process translated yields SHALL load the
checked-in `doxygen-javascript.conf` alias contract or an exactly equivalent
configuration:

```text
ALIASES += jsyields="@par Yields^^"
```

The alias introduces the logical newline required for a Doxygen `Yields` paragraph
without changing the filter's physical line count.

Canonical `@deprecated Description.` and `@see Reference` records are currently
accepted as native-compatible forms under ADR-020.  The filter SHALL preserve them
unchanged.  Do not normalize `@see` to `@sa`, wrap native-compatible tags in aliases,
or claim another same-named JSDoc/Doxygen tag is supported without focused
pass-through and downstream semantic evidence.

The singular JSDoc synonym `@return`, untyped returns, typed returns without
descriptions, description-only `@throws`, type-only `@throws`, throws types with
whitespace, description-only `@yields`, type-only `@yields`, continuation records,
dotted properties, optional dotted properties, rest parameters, destructured
parameter documentation, and one-line JSDoc blocks remain unsupported and should
pass through visibly.

Future JSDoc support should remain narrow and evidence-driven.  Prefer visible
unsupported syntax to speculative semantic claims.  Do not add JavaScript parsing,
type inference, inferred behavior, broad JSDoc semantics, or blanket native-tag
support without explicit governance and focused tests.

All governed filter transformations preserve one physical output record for every
input record.  `test/run-tests.sh` verifies physical line-count equality for every
fixture.  Doxygen's input-filter contract associates filtered text with source
locations and source-browser anchors, so proposals that add or remove physical
lines require explicit governance plus integration evidence rather than being
treated as harmless formatting changes.

Copied Python implementation, tests, ADRs, and workflow history may remain during
migration as reference material.  They are not current JavaScript capability
claims where ADR-012 and later JavaScript-specific decisions supersede their
Python-specific contracts.

## Portability and Testing

Portable AWK is the compatibility floor.  Production filter source must run under
at least `mawk` and GNU awk.

Behavior-focused JavaScript fixtures live under `test/fixtures/`.  Golden filtered
output lives under `test/expected/`.  `test/run-tests.sh` emits TAP version 13 and
verifies line-count preservation for every fixture.

Use:

```sh
make test AWK_BIN=mawk
make test AWK_BIN=gawk
```

The current TAP suite proves ordinary source pass-through; required-parameter
translation; optional-parameter translation with and without compact documented
defaults; visible pass-through of unsupported dotted property notation; canonical
typed `@returns` translation; visible pass-through of singular `@return`;
canonical typed-and-described `@throws` translation; visible pass-through of
description-only and type-only throws forms; canonical typed `@yields`
translation; visible pass-through of description-only and type-only yields forms;
and unchanged pass-through of accepted native-compatible `@deprecated` and `@see`
records.  Add a focused fixture and expected output when adding each new supported
translation or native-compatible behavior.  Tests should protect externally
observable behavior rather than internal helper structure.

ADR-018 adds a separate downstream integration surface beneath `test/doxygen/`.
ADR-019 extends that surface with the alias-backed yields representation.  ADR-020
uses the same surface to prove native-compatible semantics.  Use:

```sh
make test-doxygen AWK_BIN=mawk
make test-doxygen AWK_BIN=gawk
```

The integration configuration parses `.js` input as JavaScript, applies the
maintained filter through Doxygen's input-filter mechanism, loads
`doxygen-javascript.conf`, generates XML, and checks semantic structure for
governed parameter, return, exception, yield, deprecation, and see-also forms.
The yields integration assertions SHALL verify both a dedicated `Yields` paragraph
and source-location evidence for the generator fixture.  Native-compatible tag
assertions SHALL prove that unchanged source records are interpreted by Doxygen as
the intended semantic structures.  CI SHALL exercise this path under both
portable-AWK implementations.  Keep this surface separate from `make test` so
textual filter failures and downstream Doxygen failures remain independently
diagnosable.

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

Project self-documentation and JavaScript/Doxygen integration are separate
capabilities with separate evidence.  Passing one does not substitute for the
other.

## Deferred Infrastructure

Generated consumer artifacts, checksums, semantic-version release publication,
and release-artifact canaries remain deferred under ADR-012 and ADR-015.  Do not
add no-op compatibility targets merely to make copied workflows succeed.

## Engineering Approach

Keep changes surgical and reviewable.  Accuracy is more important than apparent
completeness.  Distinguish implemented behavior from planned behavior, state
uncertainty explicitly, and do not widen the parser, generated representation,
native-compatible support boundary, consumer configuration, or documentation
boundary without governance and focused executable evidence.
