# AGENTS.md

## Repository Purpose

`javascript-doxygen` provides a documentation-led Doxygen input filter for
JavaScript.  Maintained JavaScript should remain idiomatic JavaScript; translation
belongs at the Doxygen boundary rather than in a second maintained documentation
dialect.

The maintained filter is `doxygen-javascript.awk`.

The current implementation translates only the accepted canonical required JSDoc
parameter form governed by ADR-013.  Unsupported JSDoc constructs remain visible
unchanged.  Do not claim broader JSDoc translation, JavaScript semantic analysis,
Doxygen integration, generated consumer artifacts, or release support until
executable evidence and governing decisions exist.

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
adds the first structured translation: canonical required parameters written as
`@param {Type} name - Description.` are converted to a line-preserving
Doxygen-facing representation with the parameter name first and the type retained
as visible prose.

Optional/defaulted parameters, dotted properties, rest parameters, destructured
parameter documentation, one-line JSDoc blocks, continuation records, and tags
other than `@param` remain unsupported by ADR-013 and should pass through visibly.

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

The current suite proves ordinary source pass-through, required-parameter
translation, and visible pass-through of an unsupported optional/defaulted
parameter.  Add a focused fixture and expected output when adding each new
supported translation behavior.  Tests should protect externally observable
behavior rather than internal helper structure.

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
