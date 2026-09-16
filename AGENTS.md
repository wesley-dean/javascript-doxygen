# AGENTS.md

## Repository Purpose

`javascript-doxygen` provides a documentation-led Doxygen input filter for
JavaScript.  Maintained JavaScript should remain idiomatic JavaScript; translation
belongs at the Doxygen boundary rather than in a second maintained documentation
dialect.

The maintained filter is `doxygen-javascript.awk`.

The current implementation translates the accepted simple-parameter JSDoc forms
governed by ADR-013 and ADR-014, canonical typed `@returns` records governed by
ADR-016, canonical typed-and-described `@throws` records governed by ADR-017,
canonical typed `@yields` records governed by ADR-019, canonical virtual `@typedef`
records governed by ADR-021, canonical child `@property` records governed by
ADR-022, and canonical named `@callback` contracts governed by ADR-023.  ADR-018
exercises governed forms through Doxygen's JavaScript parser, ADR-020 establishes
native-compatible pass-through for proven `@deprecated` and `@see` forms, ADR-024
establishes consumer-alias rendering for byte-preserved canonical `@type`
annotations, ADR-025 establishes generated development, ordinary, and minified AWK
build artifacts with adjacent SHA-256 files, ADR-026 governs semantic-version
publication of those exact artifacts plus post-publication canary evidence, and
ADR-027 normalizes generated, released, and vendored artifact names to the sibling
`doxygen-<language>.awk` convention.  Unsupported JSDoc constructs remain visible
unchanged.  Do not claim broader JSDoc translation, native compatibility,
consumer-alias support, JavaScript semantic analysis, or release behavior beyond
the accepted governance and executable evidence.

## Governing Documentation

Before changing the repository, review `README.md`, this file, the applicable
files under `doc/standards/`, every ADR in `doc/adr/*.md`, and
`doc/decisions.md`.

Accepted ADRs are governance.  Consequential parser, interface, portability,
compatibility, documentation-publication, integration, consumer-configuration,
virtual-type representation, build/distribution, or release changes require an ADR
unless existing governance already covers the decision.

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

The shared standard defines valid maintained-source forms.  Filter and consumer-
configuration support are separate, narrower contracts governed by this
repository's accepted ADRs and regression tests.  Do not infer that
`doxygen-javascript.awk` translates or that Doxygen natively or through aliases
supports a JSDoc construct merely because the shared standard permits that
construct.

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
TAP and integration evidence prove that compatibility.  ADR-021 represents
canonical virtual JSDoc typedefs as Doxygen related pages so they remain named and
cross-referenceable without fabricating JavaScript declarations.  ADR-022 adds
canonical simple properties as structured child documentation on those pages.
ADR-023 represents named simple callbacks as a distinct virtual-page entity and
reuses already-governed parameter and return translations for callback signatures.
ADR-024 supports canonical `@type {Type}` annotations by leaving the maintained
JSDoc record unchanged and defining its Doxygen presentation entirely in consumer
configuration.  ADR-025 establishes the JavaScript-specific generated artifact,
checksum, build-dependency, and source/dist parity contract.  ADR-026 publishes
those generated artifacts as semantic-versioned GitHub release assets and adds a
post-publication exact-public-bytes canary.  ADR-027 supersedes only the artifact
and consumer filename portions of ADR-025 and ADR-026, standardizing them on the
Doxygen-first sibling convention and removing the copied root Python filter.

Supported parameter, virtual typedef, governed typedef-property, and callback names
remain simple JavaScript identifiers.  The filter keeps type expressions and
supported optional defaults as textual documentation data rather than interpreting
them as JavaScript semantics.  Compact defaults must be non-empty and contain
neither whitespace nor `]` in the current grammar.

Canonical typed returns use `@returns {Type} Description.` and are emitted as
`@returns Description. Type: Type.`.  Canonical typed exceptions use
`@throws {Type} Description.` with a compact non-whitespace exception type and are
emitted as `@throws Type Description.`.  Canonical typed yields use
`@yields {Type} Description.` and are emitted as
`@jsyields Type: Type. Description.`.

`@jsyields` is generated Doxygen-facing syntax only.  Maintainers SHALL continue
to write JSDoc `@yields`.  A consuming repository SHALL define the governed alias
in its own Doxyfile:

```text
ALIASES += jsyields="@par Yields^^"
```

The alias introduces the logical newline required for a Doxygen `Yields` paragraph
without changing the filter's physical line count.  The checked-in
`doxygen-javascript.conf` file is the repository's canonical integration-test and
reference copy of the alias configuration; it is not a downstream runtime
dependency.

Canonical `@deprecated Description.` and `@see Reference` records are currently
accepted as native-compatible forms under ADR-020.  The filter SHALL preserve them
unchanged.  Do not normalize `@see` to `@sa`, wrap native-compatible tags in aliases,
or claim another same-named JSDoc/Doxygen tag is supported without focused
pass-through and downstream semantic evidence.

Canonical virtual typedefs use `@typedef {Type} Name`.  ADR-021 requires the
filter to emit a generated `@jstypedef` alias invocation on the same physical line.
The consumer-owned Doxyfile alias expands to a Doxygen related page whose visible
title is the exact JSDoc typedef name.  The page is a documentation entity, not a
runtime JavaScript class, struct, interface, function, variable, or native typedef
declaration.  Do not synthesize fake JavaScript declarations to create
documentation symbols.

Virtual typedef page labels are deterministic generated identifiers.  Maintained
source authors SHALL NOT write or duplicate those labels.  Generated labels use a
lowercase alphanumeric encoding so JavaScript case-sensitive identifiers remain
distinct without relying on Doxygen page-name case behavior.  Consumers may use the
generated labels as Doxygen `@ref` targets where the generated representation needs
cross-references.

Canonical typedef properties use `@property {Type} name - Description.` and are
supported only after a governed virtual typedef has already been established in
the same JSDoc block.  ADR-022 requires the filter to emit a generated
`@jsproperty` alias invocation on the same physical line.  The alias renders a
`Property: name` paragraph on the existing virtual typedef page.  The property
SHALL NOT become a fake JavaScript member, field, variable, accessor, or standalone
page.  A property outside a governed virtual typedef block remains unchanged.

Canonical callbacks use `@callback Name` with a simple JavaScript identifier.
ADR-023 requires the filter to emit a line-preserving generated `@jscallback`
record whose alias creates a related page titled with the exact callback name.
Callback labels use a distinct `jsdocvirtualcallback` namespace so a callback and a
typedef with the same maintained name cannot collide.  The callback page is a
virtual documentation entity; the filter SHALL NOT synthesize a JavaScript or
Doxygen function declaration.

Already-governed canonical `@param` and typed `@returns` records in the same
callback block retain their existing translations.  Integration evidence SHALL
prove that Doxygen renders those sections inside the callback page.  Do not add a
second callback-specific parameter or return representation while the existing
representation remains sufficient.

Canonical symbol type annotations use:

```text
@type {Type}
```

ADR-024 requires `doxygen-javascript.awk` to preserve this maintained JSDoc record
unchanged.  A consuming repository that uses this governed rendering SHALL define
the alias in its own Doxyfile:

```text
ALIASES += type="@par Type^^"
```

The alias renders the maintained expression as a `Type` paragraph attached to the
symbol documented by the surrounding block.  The braces and expression remain
textual documentation data.  Do not parse, normalize, infer, validate, or claim
native Doxygen type semantics from this representation.  The alias is
presentation, not type-system integration.

The singular JSDoc synonym `@return`, untyped returns, typed returns without
descriptions, description-only `@throws`, type-only `@throws`, throws types with
whitespace, description-only `@yields`, type-only `@yields`, unsupported typedef
forms, continuation records, dotted properties, optional dotted properties, rest
parameters, destructured parameter documentation, standalone properties, complex
callback namepaths such as `Requester~requestCallback`, automatic linking of type
expressions to virtual typedef or callback pages, and one-line JSDoc blocks remain
unsupported unless a later accepted decision governs them.

Future JSDoc support should remain narrow and evidence-driven.  Prefer visible
unsupported syntax to speculative semantic claims.  Do not add JavaScript parsing,
type inference, inferred behavior, broad JSDoc semantics, blanket native-tag
support, blanket consumer-alias support, or synthetic runtime declarations without
explicit governance and focused tests.

All governed filter transformations preserve one physical output record for every
input record.  `test/run-tests.sh` verifies physical line-count equality for every
fixture.  ADR-024 `@type` support is stronger still at the filter boundary: the
maintained record is byte-preserved.  Doxygen's input-filter contract associates
filtered text with source locations and source-browser anchors, so proposals that
add or remove physical lines require explicit governance plus integration evidence
rather than being treated as harmless formatting changes.

Historical copied Python tests, ADRs, and workflow references may remain during
migration as reference material.  They are not current JavaScript capability
claims where ADR-012 and later JavaScript-specific decisions supersede their
Python-specific contracts.  ADR-027 removes the copied root `doxygen-python.awk`
implementation; the independent `python-doxygen` repository is the maintained
source for that filter.

## Consumer Integration

Downstream consumption follows the sibling filter model.  A consuming repository
uses `bashdeps` to pin one released JavaScript filter and materializes that one
runtime dependency conventionally as:

```text
vendor/doxygen-javascript.awk
```

The consumer owns its Doxyfile.  It SHALL map JavaScript files to Doxygen's
JavaScript parser, apply the vendored filter through `FILTER_PATTERNS`, and include
the governed alias definitions needed by the supported alias-backed
representations.  The README is the human-facing setup reference for the exact
current Doxyfile block.

Do not turn `doxygen-javascript.conf` into a second Bashdeps dependency.  It exists
to keep repository integration tests and the reference alias contract inspectable.
The downstream runtime dependency model remains exactly one AWK filter file.

## Build and Distribution

ADR-025 establishes the local generated-artifact lifecycle; ADR-027 normalizes its
filenames.  The current build outputs are:

```text
dist/doxygen-javascript.dev.awk
dist/doxygen-javascript.dev.awk.sha256
dist/doxygen-javascript.awk
dist/doxygen-javascript.awk.sha256
dist/doxygen-javascript.min.awk
dist/doxygen-javascript.min.awk.sha256
```

The development artifact retains all maintained AWK documentation.  The ordinary
artifact removes only project-governed `##` Doxygen documentation records.  The
minified artifact is derived from the ordinary artifact body by the pinned
released AWK Minifier synchronized through `bashdeps`; generated provenance is kept
outside the minifier input.

Build dependency acquisition and build execution are separate boundaries:

```sh
make deps
make deps-check
make build
```

`make deps` may use the network.  `make deps-check` and `make build` are offline and
non-repairing.  `make all` is the convenience lifecycle that runs dependency
preparation and then builds all six outputs.  Do not add hidden downloads to
`make build`, silently fall back to another minifier, or use the current candidate
as its own production minifier.

`dependencies.txt` owns build dependencies.  `dependencies-docs.txt` owns
self-documentation dependencies.  Both may materialize files under `vendor/`;
Bashdeps synchronization does not prune files omitted from the current manifest.

Generated `dist/` content is untracked.  Every generated AWK artifact must preserve
the maintained filter's tested semantics and must have a valid adjacent SHA-256
file in ordinary `sha256sum`-compatible format.

## Release Publication

ADR-026 governs the semantic-version release interface, with current filenames
normalized by ADR-027.  The versioning workflow runs on pushes to `main` and may be
invoked manually.  It SHALL calculate the prospective version without creating a
tag, validate maintained source, run `make all VERSION=<version> AWK_BIN=mawk`, and
exercise the exact generated artifacts under both `mawk` and GNU awk plus Doxygen
before creating a release.

The release SHALL publish exactly the three current AWK artifacts and their three
adjacent SHA-256 files.  The ordinary `doxygen-javascript.awk` file is the canonical
normal Bashdeps consumer artifact.  Development and minified files are alternate
published representations and do not add runtime dependencies.

Release v0.0.3 remains historically valid with its original
`javascript-doxygen*.awk` filenames.  Beginning with the first ADR-027 release, the
release interface uses only the normalized `doxygen-javascript*.awk` names.
Historical release assets SHALL NOT be renamed or replaced merely to match the
current convention.

The release tag SHALL be created only after validation succeeds and SHALL identify
the exact validated commit.  Workflow YAML SHALL NOT duplicate Make-owned build,
minification, checksum, TAP, or Doxygen logic.

A dependent post-publication canary SHALL download all six public release assets,
verify the three hashes, and run TAP plus Doxygen integration against every
downloaded AWK artifact under both supported AWK implementations.  The canary is
verification only: it SHALL NOT advance stable dependency pins or mutate unrelated
repository state.

`doxygen-javascript.conf` remains repository reference/integration data and SHALL
NOT become a release runtime asset.  Normal consumers pin a specific semantic
version of `doxygen-javascript.awk`, its public release URL, and its expected digest
through Bashdeps.  Consumers remaining on v0.0.3 use that release's historical
`javascript-doxygen.awk` name.

## Portability and Testing

Portable AWK is the compatibility floor.  Production filter source and generated
artifacts must run under at least `mawk` and GNU awk.

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
unchanged pass-through of accepted native-compatible `@deprecated` and `@see`
records; canonical virtual typedef translation; visible pass-through of unsupported
typedef forms; canonical property translation under a governed typedef; visible
pass-through of a standalone property; canonical named callback translation;
visible pass-through of an unsupported callback namepath; and byte-preserved
canonical `@type` annotation pass-through.  Add a focused fixture and expected
output when adding each new supported translation, native-compatible behavior, or
consumer-alias behavior.  Tests should protect externally observable behavior
rather than internal helper structure.

ADR-018 adds a separate downstream integration surface beneath `test/doxygen/`.
ADR-019 extends that surface with the alias-backed yields representation.  ADR-020
uses the same surface to prove native-compatible semantics.  ADR-021 adds named
related-page and cross-reference evidence for virtual typedefs.  ADR-022 adds
property-on-page evidence.  ADR-023 adds named callback-page evidence with
parameter, return, and cross-reference assertions.  ADR-024 adds symbol-local
`Type` paragraph evidence for unchanged canonical JSDoc `@type` records.  Use:

```sh
make test-doxygen AWK_BIN=mawk
make test-doxygen AWK_BIN=gawk
```

The repository integration configuration parses `.js` input as JavaScript, applies
the selected filter through Doxygen's input-filter mechanism, loads the
repository-only `doxygen-javascript.conf` reference fragment, generates XML, and
checks semantic structure for governed parameter, return, exception, yield,
deprecation, see-also, virtual typedef, typedef-property, callback, and type-
annotation forms.  The yields integration assertions SHALL verify both a dedicated
`Yields` paragraph and source-location evidence for the generator fixture.  Native-
compatible tag assertions SHALL prove that unchanged source records are interpreted
by Doxygen as the intended semantic structures.  Virtual typedef assertions SHALL
prove that Doxygen creates a named related page, retains the maintained prose and
base type, and resolves a reference to the generated page label.  Property
assertions SHALL prove that the property heading, type, and description occur
inside the generated virtual typedef page.  Callback assertions SHALL prove named
page creation, parameter and return sections inside that page, and resolved
references to the generated callback label.  Type-annotation assertions SHALL prove
that the maintained `@type` record remains unchanged through the filter and that
Doxygen attaches the configured `Type` paragraph and retained expression to the
documented symbol.  CI SHALL exercise this path under both portable-AWK
implementations.  Keep this surface separate from `make test` so textual filter
failures and downstream Doxygen failures remain independently diagnosable.

ADR-025 adds generated-artifact parity surfaces.  Use:

```sh
make test-dist AWK_BIN=mawk
make test-dist AWK_BIN=gawk
make test-dist-doxygen AWK_BIN=mawk
make test-dist-doxygen AWK_BIN=gawk
```

`test-dist` validates artifact shape, all adjacent checksums, and the full TAP suite
against development, ordinary, and minified artifacts.  `test-dist-doxygen`
exercises each generated artifact through the same Doxygen integration contract.
CI runs both artifact surfaces under `mawk` and GNU awk after `make all`.

ADR-026 extends the same evidence to release publication.  Pre-publication gates
exercise the exact generated release candidates; the post-publication canary then
repeats TAP and Doxygen integration against the exact public release bytes.

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

Do not reactivate copied Python-specific release paths or add no-op compatibility
targets.  Future release changes SHALL preserve ADR-025, ADR-026, and ADR-027 unless
a new or superseding accepted decision explicitly changes the public contract.

## Engineering Approach

Keep changes surgical and reviewable.  Accuracy is more important than apparent
completeness.  Distinguish implemented behavior from planned behavior, state
uncertainty explicitly, and do not widen the parser, generated representation,
native-compatible or consumer-alias support boundary, virtual-type entity model,
consumer configuration, build/distribution contract, or release boundary without
governance and focused executable evidence.