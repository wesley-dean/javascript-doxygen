# Architecture Decisions

## Shared coding standards adoption

ADR-011 establishes the managed shared-standards model beneath `doc/standards/`,
with provenance recorded in `.codingstandardrc`.  The current pinned snapshot is
`coding_standards@v1.0.6`, which adds the shared JavaScript documentation standard
and its example.  Applicable imported standards are repository governance, while
accepted local ADRs and explicit local policy remain the mechanism for visible
refinements or exceptions; imported files are not edited locally.  The complete
library is committed for inspectability even though presence does not imply
applicability, and no permanent standards-update machinery is installed.  See
[ADR-011](adr/ADR-011-adopt-shared-coding-standards.md).

## JavaScript filter bootstrap and TAP regression contract

ADR-012 establishes `doxygen-javascript.awk` as the maintained JavaScript filter
and deliberately limits the first milestone to source pass-through.  Focused
fixtures live beneath `test/fixtures/`, golden output beneath `test/expected/`,
and `test/run-tests.sh` emits TAP version 13; `make test` runs the same suite with
portable AWK implementations.  JavaScript/Doxygen integration and release
workflows were initially deferred rather than satisfied with no-op compatibility
targets; ADR-015 later restored independent project self-documentation, ADR-018
later established JavaScript/Doxygen integration testing, ADR-025 later
established local JavaScript distribution artifacts, and ADR-026 later establishes
JavaScript-specific release publication.  See
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-015](adr/ADR-015-restore-project-self-documentation.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-025](adr/ADR-025-build-javascript-distribution-artifacts.md), and
[ADR-026](adr/ADR-026-publish-javascript-release-artifacts.md).

## Required JSDoc parameter translation

ADR-013 adds the first structured JavaScript documentation translation.  Canonical
required parameters written as `@param {Type} name - Description.` are rewritten
at the Doxygen boundary to a line-preserving representation with the parameter
name first and the maintained JSDoc type retained as visible prose.  Its first
recognition boundary intentionally excluded optional/defaulted and more complex
parameter names; later decisions may expand those forms without changing ADR-013's
historical scope.  See
[ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md).

## Optional JSDoc parameter translation

ADR-014 extends the simple-parameter contract to canonical optional parameters
written as `[name]` and `[name=default]`, where supported defaults are compact,
non-empty tokens containing neither whitespace nor `]`.  The Doxygen-facing
representation keeps the simple parameter name first, retains the JSDoc type as
visible prose, marks optionality explicitly, and preserves the supported default
textually without evaluating or normalizing it.  Dotted properties and other
complex name forms remain unchanged so their semantics can be governed
separately.  See [ADR-014](adr/ADR-014-translate-optional-jsdoc-parameters.md).

## Project self-documentation and Pages publication

ADR-015 separates repository self-documentation from JavaScript/Doxygen
integration.  The maintained AWK filter source is documented with pinned released
`awk-doxygen`, the Bash TAP harness is documented with pinned released
`bash-doxygen`, and `adrctl` generates the ephemeral ADR landing page.  Pull
requests exercise this path through a documentation canary, while pushes to
`main` publish the generated `doc/reference/` tree to GitHub Pages.  ADR-018 later
adds separate JavaScript/Doxygen integration evidence without changing this
self-documentation contract.  See
[ADR-015](adr/ADR-015-restore-project-self-documentation.md) and
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md).

## Typed JSDoc return translation

ADR-016 adds the first non-parameter JSDoc translation.  Canonical typed return
records written as `@returns {Type} Description.` retain the Doxygen-supported
`@returns` command while moving the maintained JSDoc type expression into visible
`Type:` prose on the same output line.  Type expressions are preserved textually
rather than validated or inferred; singular `@return`, untyped returns, typed
returns without descriptions, and continuation records remain unchanged and
visible.  See [ADR-016](adr/ADR-016-translate-typed-jsdoc-returns.md).

## Typed JSDoc exception translation

ADR-017 adds canonical typed-and-described exception translation.  Records written
as `@throws {Type} Description.` retain Doxygen's native `@throws` command and move
the compact maintained exception type into Doxygen's exception-object position by
removing only the JSDoc braces.  The type and description remain textual source
data; description-only throws, type-only throws, types containing whitespace,
continuation records, and ambiguous forms remain unchanged and visible.  See
[ADR-017](adr/ADR-017-translate-typed-jsdoc-throws.md).

## JavaScript/Doxygen integration testing

ADR-018 promotes JavaScript/Doxygen integration from a deferred capability to an
explicitly tested boundary for already-governed translations.  Dedicated fixtures
beneath `test/doxygen/` are parsed with Doxygen's JavaScript parser while
`doxygen-javascript.awk` remains an input-filter documentation translator, and
`make test-doxygen` asserts generated XML structure.  CI runs the integration path
under both `mawk` and GNU awk, while `make test` remains the lightweight TAP
surface.  The decision also makes physical line preservation an explicit
integration concern because Doxygen associates filtered source with source
locations and source-browser anchors.  See
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md).

## Native-compatible JSDoc tags

ADR-020 establishes that canonical JSDoc forms which Doxygen already accepts with
compatible grammar and meaning should pass through unchanged rather than gaining
unnecessary translator logic.  The first accepted forms are
`@deprecated Description.` and `@see Reference`, each protected by exact
pass-through fixtures, the global physical-line-count invariant, and downstream
Doxygen semantic assertions.  Matching tag names alone do not establish native
compatibility; future forms still require focused evidence.  See
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md).

## Virtual JSDoc typedef representation

ADR-021 represents canonical named JSDoc virtual typedefs as Doxygen related pages
rather than pretending they are runtime JavaScript declarations.  The filter emits
a line-preserving generated `@jstypedef` alias invocation with a deterministic
lowercase internal page label, while the visible page title remains the exact JSDoc
typedef name and the maintained base type remains visible documentation.  This
provides a named, navigable, `@ref`-addressable documentation entity without
fabricating a class, struct, interface, function, variable, or native typedef;
property representation is governed separately by ADR-022, named callback
representation is governed separately by ADR-023, and canonical symbol `@type`
annotations are governed separately by ADR-024.  Automatic type-expression linking
remains a future decision.  See
[ADR-021](adr/ADR-021-represent-virtual-jsdoc-typedefs-as-related-pages.md).

## Virtual JSDoc typedef property representation

ADR-022 renders canonical `@property {Type} name - Description.` records as
structured child paragraphs on an ADR-021 virtual typedef page.  Translation is
allowed only after a supported typedef has already been established in the same
JSDoc block; standalone or unsupported property forms remain visibly unchanged.
The property stays documentation rather than becoming a fake JavaScript member or
standalone Doxygen entity, and alias expansion preserves physical line
correspondence.  See
[ADR-022](adr/ADR-022-render-jsdoc-typedef-properties-on-virtual-type-pages.md).

## Named JSDoc callback representation

ADR-023 represents canonical simple `@callback Name` contracts as a second kind of
Doxygen related page rather than as synthetic JavaScript or Doxygen function
symbols.  Callback labels use a distinct deterministic `jsdocvirtualcallback`
namespace so callback and typedef entities with the same maintained name cannot
collide.  Already-governed simple parameter and typed return translations are
reused inside the callback page, with downstream Doxygen evidence proving the
parameter section, return section, and cross-reference target.  Complex JSDoc
namepaths and automatic type-expression linking remain deferred; canonical
symbol-local `@type` rendering is governed separately by ADR-024.  See
[ADR-023](adr/ADR-023-represent-jsdoc-callbacks-as-virtual-pages.md).

## Canonical JSDoc type annotation rendering

ADR-024 supports canonical `@type {Type}` annotations without adding an AWK
translation.  The maintained JSDoc record remains byte-preserved through
`doxygen-javascript.awk`, while the governed consumer alias
`type="@par Type^^"` lets Doxygen render the following maintained expression as a
symbol-local `Type` paragraph.  The expression, including its braces, remains
textual documentation data and is not parsed, normalized, inferred, validated, or
claimed as a native Doxygen semantic type.  Focused TAP and Doxygen integration
evidence under both supported AWK implementations prove pass-through, line
preservation, symbol attachment, and retained type text.  ADR-025 later clarifies
that downstream consumers maintain the required alias in their own Doxyfile; the
checked-in configuration fragment remains repository reference/test material.  See
[ADR-024](adr/ADR-024-preserve-jsdoc-type-with-consumer-alias.md) and
[ADR-025](adr/ADR-025-build-javascript-distribution-artifacts.md).

## JavaScript distribution build artifacts

ADR-025 establishes the JavaScript-specific generated build boundary.  `make all`
uses Bashdeps to prepare pinned AWK Minifier v0.2.1 and produces development,
ordinary, and minified `dist/javascript-doxygen*.awk` artifacts plus one adjacent
SHA-256 file for each; `make build` remains offline over already prepared and
verified dependency state.  The three generated filters run through the same TAP
suite and Doxygen integration surface as maintained source under both supported AWK
implementations.  The downstream runtime model remains one Bashdeps-managed AWK
filter in the consumer's `vendor/` directory, while required aliases live in the
consumer-owned Doxyfile.  ADR-026 publishes these exact generated outputs without
changing that one-file runtime contract.  See
[ADR-025](adr/ADR-025-build-javascript-distribution-artifacts.md) and
[ADR-026](adr/ADR-026-publish-javascript-release-artifacts.md).

## JavaScript release publication

ADR-026 establishes semantic-version publication of the exact ADR-025 build
outputs.  The ordinary `javascript-doxygen.awk` asset is the canonical normal
Bashdeps consumer artifact; `.dev` and `.min` are alternate published variants,
and all three adjacent SHA-256 files are published as verification metadata.  The
workflow calculates a version without creating a tag, validates maintained source
and all generated variants under `mawk` and GNU awk plus Doxygen, then creates the
release tag and uploads all six exact Make-produced files.  A dependent
post-publication canary downloads all six public assets, verifies all hashes, and
re-exercises every published filter under both supported AWKs and Doxygen.  See
[ADR-026](adr/ADR-026-publish-javascript-release-artifacts.md).

## Capability scope and epistemic honesty

The project distinguishes implemented behavior from planned behavior and makes
capability claims only when evidence supports them.  ADR-012 established the
initial pass-through baseline, ADR-013 added required simple parameters, ADR-014
added optional simple parameters with and without compact documented defaults,
ADR-016 added canonical typed return translation, ADR-017 added canonical typed
exception translation, ADR-019 adds canonical typed yield translation, ADR-020
adds evidence-backed native-compatible support for `@deprecated` and `@see`,
ADR-021 adds named virtual typedef pages, ADR-022 adds canonical properties of those
virtual typedefs, ADR-023 adds named virtual callback pages with governed signature
documentation, ADR-024 adds consumer-alias rendering for byte-preserved canonical
symbol `@type` annotations, ADR-025 adds locally generated and verified JavaScript
distribution artifacts, and ADR-026 adds semantic-version release publication plus
post-publication canary evidence.  ADR-015 establishes self-documentation as a
separate supported capability, while ADR-018 adds downstream Doxygen evidence for
governed forms.  Broader JSDoc support and automatic type-expression linking remain
deferred until separately governed and proven.  See
[ADR-000](adr/ADR-000-capability-scope-and-epistemic-honesty.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md),
[ADR-014](adr/ADR-014-translate-optional-jsdoc-parameters.md),
[ADR-015](adr/ADR-015-restore-project-self-documentation.md),
[ADR-016](adr/ADR-016-translate-typed-jsdoc-returns.md),
[ADR-017](adr/ADR-017-translate-typed-jsdoc-throws.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md),
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md),
[ADR-021](adr/ADR-021-represent-virtual-jsdoc-typedefs-as-related-pages.md),
[ADR-022](adr/ADR-022-render-jsdoc-typedef-properties-on-virtual-type-pages.md),
[ADR-023](adr/ADR-023-represent-jsdoc-callbacks-as-virtual-pages.md),
[ADR-024](adr/ADR-024-preserve-jsdoc-type-with-consumer-alias.md),
[ADR-025](adr/ADR-025-build-javascript-distribution-artifacts.md), and
[ADR-026](adr/ADR-026-publish-javascript-release-artifacts.md).

## Supported Python documentation scope

ADR-001 established the copied Python milestone-1 boundary: conservatively
identifiable triple-double-quoted module, class, function, and method docstrings
with three structured field translations.  ADR-009 supersedes only the portions
of that boundary covering raw-prefix recognition, deterministic one-line prose
docstrings, and single-physical-line declaration headers.  ADR-012 supersedes
these Python-specific capability claims for the maintained JavaScript filter; the
older decisions remain migration history and reference material.  See
[ADR-001](adr/ADR-001-define-supported-python-documentation-scope.md),
[ADR-009](adr/ADR-009-expand-standards-conforming-docstring-recognition.md), and
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md).

## Doxygen-facing representation

The copied Python filter preserves Python declarations and docstrings while
translating governed field syntax, with `PYTHON_DOCSTRING = NO` required by its
maintained Doxygen integration.  That representation remains historical reference
for this repository.  ADR-013 establishes the first JavaScript Doxygen-facing
translation for required `@param` records, ADR-014 extends that representation to
simple optional parameters, ADR-016 applies a line-preserving textual type
strategy to canonical `@returns` records, and ADR-017 maps canonical exception
types into Doxygen's native `@throws` exception-object position.  ADR-018 verifies
selected representations through Doxygen-generated XML and establishes line
preservation as an integration property.  ADR-019 preserves that property for
yields by emitting a single-line `@jsyields` command whose logical paragraph break
is supplied by a consumer-side Doxygen alias.  ADR-020 establishes that no
generated representation is preferable when maintained JSDoc is already a native-
compatible Doxygen command.  ADR-021 extends the alias-backed model to virtual
typedefs, using related pages to preserve named identity without inventing runtime
source semantics.  ADR-022 extends the same page model with alias-backed property
paragraphs that remain child documentation rather than synthetic members.  ADR-023
adds a distinct related-page namespace for named callbacks while reusing the
existing parameter and return representations as callback-page sections.  ADR-024
adds a third pass-through pattern: maintained `@type` syntax is unchanged by the
filter and receives only presentation semantics from a consumer-side Doxygen alias.
ADR-025 clarifies that those aliases belong in the downstream consumer's Doxyfile;
the repository configuration fragment remains integration/reference data rather
than a second runtime dependency.  See
[ADR-002](adr/ADR-002-preserve-python-and-translate-docstrings.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md),
[ADR-014](adr/ADR-014-translate-optional-jsdoc-parameters.md),
[ADR-016](adr/ADR-016-translate-typed-jsdoc-returns.md),
[ADR-017](adr/ADR-017-translate-typed-jsdoc-throws.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md),
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md),
[ADR-021](adr/ADR-021-represent-virtual-jsdoc-typedefs-as-related-pages.md),
[ADR-022](adr/ADR-022-render-jsdoc-typedef-properties-on-virtual-type-pages.md),
[ADR-023](adr/ADR-023-represent-jsdoc-callbacks-as-virtual-pages.md),
[ADR-024](adr/ADR-024-preserve-jsdoc-type-with-consumer-alias.md), and
[ADR-025](adr/ADR-025-build-javascript-distribution-artifacts.md).

## Yields translation

ADR-003 records the copied Python `:yields:` representation as a dedicated Doxygen
`Yields` paragraph produced by adding a physical filter line.  ADR-019 establishes
the JavaScript-specific contract instead: canonical `@yields {Type} Description.`
records become one-line `@jsyields Type: Type. Description.` records, and the
governed alias expands that generated command into a logical `Yields` paragraph
inside Doxygen.  ADR-025 clarifies that consumers define this alias in their own
Doxyfile, while `doxygen-javascript.conf` remains repository reference/test data.
This preserves generator semantics, the one-file runtime dependency model, and
physical line correspondence simultaneously.  Description-only and type-only
`@yields` remain unchanged.  See
[ADR-003](adr/ADR-003-define-yields-translation.md),
[ADR-016](adr/ADR-016-translate-typed-jsdoc-returns.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md), and
[ADR-025](adr/ADR-025-build-javascript-distribution-artifacts.md).

## Versioned consumer artifact

ADR-004 established the copied Python source/dist artifact boundary, and ADR-007
later governed release publication of those Python artifacts.  ADR-012 deferred a
JavaScript consumer-artifact and release contract until corresponding behavior was
defined and tested.  ADR-025 establishes the JavaScript local build artifacts,
checksums, pinned minifier lineage, and one-file downstream runtime model.  ADR-026
now establishes semantic-version publication: `javascript-doxygen.awk` is the
canonical normal Bashdeps consumer asset, with development and minified variants
published as alternatives and all three hashes published alongside them.  The
checked-in `doxygen-javascript.conf` remains repository reference/test data rather
than a release dependency.  See
[ADR-004](adr/ADR-004-build-and-release-versioned-filter.md),
[ADR-007](adr/ADR-007-publish-and-canary-exact-release-artifacts.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-025](adr/ADR-025-build-javascript-distribution-artifacts.md), and
[ADR-026](adr/ADR-026-publish-javascript-release-artifacts.md).

## Behavior-focused fixtures

ADR-005 established the value of small behavior-focused fixtures.  ADR-012 keeps
that principle while replacing the copied Python fixture paths for maintained
JavaScript behavior with `test/fixtures/` and `test/expected/`, plus TAP output
from `test/run-tests.sh`.  ADR-013 adds required-parameter coverage, ADR-014 adds
optional/compact-default coverage plus a negative property-notation boundary,
ADR-016 adds typed-return coverage plus a negative singular-`@return` boundary,
and ADR-017 adds typed-throws coverage plus negative description-only and type-only
throws boundaries.  ADR-018 complements those textual fixtures with downstream
Doxygen integration fixtures.  ADR-019 adds typed-yields positive/negative
fixtures and strengthens the TAP harness so every fixture proves physical
line-count preservation.  ADR-020 adds exact pass-through and downstream semantic
evidence for native-compatible `@deprecated` and `@see` forms.  ADR-021 adds
positive and negative typedef fixtures plus integration assertions for named page
creation and `@ref` resolution.  ADR-022 adds positive typedef-property coverage,
negative standalone-property coverage, and page-specific Doxygen assertions.
ADR-023 adds positive simple-callback translation, negative complex-namepath
pass-through, and page-specific parameter, return, and cross-reference assertions.
ADR-024 adds byte-preserved canonical `@type` coverage plus a dedicated one-symbol
Doxygen fixture proving the configured `Type` paragraph and maintained expression
attach to the documented symbol.  ADR-025 reuses those same behavior fixtures and
integration assertions against all three generated AWK artifacts, while also
checking artifact shape and SHA-256 files.  ADR-026 reuses the same suites against
the exact public release bytes in its post-publication canary.  See
[ADR-005](adr/ADR-005-use-small-behavior-focused-fixtures.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md),
[ADR-014](adr/ADR-014-translate-optional-jsdoc-parameters.md),
[ADR-016](adr/ADR-016-translate-typed-jsdoc-returns.md),
[ADR-017](adr/ADR-017-translate-typed-jsdoc-throws.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md),
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md),
[ADR-021](adr/ADR-021-represent-virtual-jsdoc-typedefs-as-related-pages.md),
[ADR-022](adr/ADR-022-render-jsdoc-typedef-properties-on-virtual-type-pages.md),
[ADR-023](adr/ADR-023-represent-jsdoc-callbacks-as-virtual-pages.md),
[ADR-024](adr/ADR-024-preserve-jsdoc-type-with-consumer-alias.md),
[ADR-025](adr/ADR-025-build-javascript-distribution-artifacts.md), and
[ADR-026](adr/ADR-026-publish-javascript-release-artifacts.md).

## Shared project infrastructure

ADR-006 directs reuse of coherent sibling-project infrastructure rather than
mechanical parity.  ADR-012 applies that principle to the JavaScript bootstrap by
retaining portable-AWK testing while deferring copied Python-specific integration
and release automation.  ADR-015 restores the sibling self-documentation pattern
because its AWK/Bash tooling matches this repository, and ADR-018 adapts the
sibling Doxygen integration pattern while keeping JavaScript as the parsed source
language and testing both supported AWK implementations.  ADR-019 deliberately
departs from the copied Python yields implementation where its extra physical line
would conflict with the JavaScript integration contract.  ADR-020 further narrows
the filter's role by preferring proven native Doxygen commands over unnecessary
rewrites.  ADR-021 reuses the established consumer-alias boundary while rejecting
synthetic declarations for virtual JavaScript documentation types.  ADR-022 reuses
that virtual-page boundary for property paragraphs rather than creating synthetic
members.  ADR-023 applies the same honest virtual-entity model to named callbacks
and reuses already-governed signature translations rather than inventing parallel
callback syntax.  ADR-024 narrows the filter's role further by using a simple
consumer alias for canonical `@type` instead of adding an unnecessary AWK parser or
rewrite.  ADR-025 adapts the three-artifact AWK Minifier build pattern and uses
Bashdeps for pinned build-tool preparation.  ADR-026 adapts sibling semantic
versioning and public release publication while deliberately delaying tag creation
until after JavaScript-specific build, checksum, semantic, and Doxygen validation.
See
[ADR-006](adr/ADR-006-adopt-sibling-build-test-and-documentation-infrastructure.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-015](adr/ADR-015-restore-project-self-documentation.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md),
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md),
[ADR-021](adr/ADR-021-represent-virtual-jsdoc-typedefs-as-related-pages.md),
[ADR-022](adr/ADR-022-render-jsdoc-typedef-properties-on-virtual-type-pages.md),
[ADR-023](adr/ADR-023-represent-jsdoc-callbacks-as-virtual-pages.md),
[ADR-024](adr/ADR-024-preserve-jsdoc-type-with-consumer-alias.md),
[ADR-025](adr/ADR-025-build-javascript-distribution-artifacts.md), and
[ADR-026](adr/ADR-026-publish-javascript-release-artifacts.md).

## Release publication and downstream pinning

ADR-026 establishes the JavaScript release interface after ADR-012's deferral and
ADR-025's local build boundary.  Pushes to `main` calculate a semantic version,
validate maintained source and all three generated artifacts, and only then create
the `v<version>` release tag and publish all three AWK variants with their SHA-256
files.  The ordinary `javascript-doxygen.awk` file is the canonical normal Bashdeps
consumer artifact; consumers pin a specific public release URL and digest while
retaining the one-file runtime dependency model.  A dependent post-publication
canary downloads all six public assets, verifies all hashes, and runs the existing
TAP and Doxygen evidence against every published filter under both supported AWKs.
See
[ADR-007](adr/ADR-007-publish-and-canary-exact-release-artifacts.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-025](adr/ADR-025-build-javascript-distribution-artifacts.md), and
[ADR-026](adr/ADR-026-publish-javascript-release-artifacts.md).

## Scenario-level program regressions

ADR-008 added larger Python program regressions alongside focused fixtures.  Those
fixtures remain migration reference material.  ADR-012 governs the focused
JavaScript TAP suite, while ADR-018 adds targeted downstream integration fixtures
rather than establishing a broad scenario-level JavaScript regression suite.
ADR-019 adds a focused generator integration fixture for yields, ADR-020 adds a
focused native-tag fixture, ADR-021 adds a focused virtual-typedef and
cross-reference fixture, ADR-022 extends that typedef fixture with one governed
property, ADR-023 adds a focused virtual-callback/signature fixture, and ADR-024
adds a focused one-symbol type-annotation fixture without broadening the scenario-
level scope.  ADR-025 applies those existing focused suites to generated artifacts
rather than adding a new scenario-level corpus.  See
[ADR-008](adr/ADR-008-add-scenario-level-program-regressions.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md),
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md),
[ADR-021](adr/ADR-021-represent-virtual-jsdoc-typedefs-as-related-pages.md),
[ADR-022](adr/ADR-022-render-jsdoc-typedef-properties-on-virtual-type-pages.md),
[ADR-023](adr/ADR-023-represent-jsdoc-callbacks-as-virtual-pages.md),
[ADR-024](adr/ADR-024-preserve-jsdoc-type-with-consumer-alias.md), and
[ADR-025](adr/ADR-025-build-javascript-distribution-artifacts.md).

## Standards-conforming docstring recognition

ADR-009 expanded the copied Python docstring recognition boundary.  ADR-012 does
not carry those Python-specific recognition rules into JavaScript.  ADR-013 adds a
separate JavaScript recognition boundary for required simple JSDoc parameters,
ADR-014 extends that boundary to bracketed simple optional parameters, ADR-016
adds a separate recognition boundary for canonical typed `@returns` records,
ADR-017 adds a typed-and-described `@throws` boundary, ADR-019 adds a canonical
typed-and-described `@yields` boundary while leaving unsupported yields forms
unchanged, ADR-021 adds a narrow simple-identifier boundary for canonical virtual
typedefs, ADR-022 adds canonical simple properties only after a supported typedef
has been established in the same JSDoc block, and ADR-023 adds a narrow simple-
identifier boundary for canonical named callbacks while leaving scoped JSDoc
namepaths unchanged.  ADR-020 does not add a parser recognition rule for
`@deprecated` or `@see`; it governs evidence-backed unchanged pass-through for
those compatible forms.  ADR-024 likewise adds no AWK parser recognition rule for
`@type`; it governs canonical maintained-source pass-through plus consumer-alias
presentation.  ADR-018 tests downstream Doxygen interpretation without widening
source semantics.  ADR-025 changes generated build packaging only and does not
widen recognition.  See
[ADR-009](adr/ADR-009-expand-standards-conforming-docstring-recognition.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md),
[ADR-014](adr/ADR-014-translate-optional-jsdoc-parameters.md),
[ADR-016](adr/ADR-016-translate-typed-jsdoc-returns.md),
[ADR-017](adr/ADR-017-translate-typed-jsdoc-throws.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md),
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md),
[ADR-021](adr/ADR-021-represent-virtual-jsdoc-typedefs-as-related-pages.md),
[ADR-022](adr/ADR-022-render-jsdoc-typedef-properties-on-virtual-type-pages.md),
[ADR-023](adr/ADR-023-represent-jsdoc-callbacks-as-virtual-pages.md),
[ADR-024](adr/ADR-024-preserve-jsdoc-type-with-consumer-alias.md), and
[ADR-025](adr/ADR-025-build-javascript-distribution-artifacts.md).

## Unannotated type fields

ADR-010 translates copied Python `:type name:` and `:rtype:` fields into dedicated
Doxygen paragraphs.  ADR-012 does not adopt an equivalent JavaScript type-field
translation.  ADR-013 and ADR-014 preserve JSDoc parameter type expressions as
visible prose, ADR-016 extends that strategy to canonical return type expressions,
ADR-017 uses Doxygen's native exception-object slot for canonical exception types,
and ADR-019 preserves canonical yield types as visible `Type:` prose within the
alias-backed `Yields` paragraph.  ADR-021 preserves a virtual typedef's maintained
base type as visible prose on its related page, and ADR-022 preserves each governed
property type as visible prose on that same page.  ADR-023 reuses ADR-013/014/016
type representation for callback parameter and return documentation.  ADR-024
establishes canonical symbol `@type {Type}` rendering as a byte-preserved maintained
record plus a consumer-defined `Type` paragraph, but it still does not establish
automatic linking or semantic interpretation of arbitrary type expressions.
ADR-018 verifies selected resulting structures, ADR-020 does not alter type
handling, and ADR-025 changes only artifact construction and consumer packaging.
See
[ADR-010](adr/ADR-010-translate-unannotated-type-fields.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md),
[ADR-014](adr/ADR-014-translate-optional-jsdoc-parameters.md),
[ADR-016](adr/ADR-016-translate-typed-jsdoc-returns.md),
[ADR-017](adr/ADR-017-translate-typed-jsdoc-throws.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md),
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md),
[ADR-021](adr/ADR-021-represent-virtual-jsdoc-typedefs-as-related-pages.md),
[ADR-022](adr/ADR-022-render-jsdoc-typedef-properties-on-virtual-type-pages.md),
[ADR-023](adr/ADR-023-represent-jsdoc-callbacks-as-virtual-pages.md),
[ADR-024](adr/ADR-024-preserve-jsdoc-type-with-consumer-alias.md), and
[ADR-025](adr/ADR-025-build-javascript-distribution-artifacts.md).