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
targets; ADR-015 later restored independent project self-documentation, and
ADR-018 later establishes JavaScript/Doxygen integration testing while leaving the
release boundary deferred.  See
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-015](adr/ADR-015-restore-project-self-documentation.md), and
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md).

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

## Capability scope and epistemic honesty

The project distinguishes implemented behavior from planned behavior and makes
capability claims only when evidence supports them.  ADR-012 established the
initial pass-through baseline, ADR-013 added required simple parameters, ADR-014
added optional simple parameters with and without compact documented defaults,
ADR-016 added canonical typed return translation, ADR-017 added canonical typed
exception translation, ADR-019 adds canonical typed yield translation, and
ADR-020 adds evidence-backed native-compatible support for `@deprecated` and
`@see`.  ADR-015 establishes self-documentation as a separate supported
capability, while ADR-018 adds downstream Doxygen evidence for governed forms.
Broader JSDoc support, consumer artifacts, and release publication remain deferred
until separately governed and proven.  See
[ADR-000](adr/ADR-000-capability-scope-and-epistemic-honesty.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md),
[ADR-014](adr/ADR-014-translate-optional-jsdoc-parameters.md),
[ADR-015](adr/ADR-015-restore-project-self-documentation.md),
[ADR-016](adr/ADR-016-translate-typed-jsdoc-returns.md),
[ADR-017](adr/ADR-017-translate-typed-jsdoc-throws.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md), and
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md).

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
generated representation is preferable when maintained JSDoc is already a
native-compatible Doxygen command.  See
[ADR-002](adr/ADR-002-preserve-python-and-translate-docstrings.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md),
[ADR-014](adr/ADR-014-translate-optional-jsdoc-parameters.md),
[ADR-016](adr/ADR-016-translate-typed-jsdoc-returns.md),
[ADR-017](adr/ADR-017-translate-typed-jsdoc-throws.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md), and
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md).

## Yields translation

ADR-003 records the copied Python `:yields:` representation as a dedicated Doxygen
`Yields` paragraph produced by adding a physical filter line.  ADR-019 establishes
the JavaScript-specific contract instead: canonical `@yields {Type} Description.`
records become one-line `@jsyields Type: Type. Description.` records, and the
checked-in `doxygen-javascript.conf` alias expands that generated command into a
logical `Yields` paragraph inside Doxygen.  This preserves generator semantics and
physical line correspondence simultaneously.  Description-only and type-only
`@yields` remain unchanged.  See
[ADR-003](adr/ADR-003-define-yields-translation.md),
[ADR-016](adr/ADR-016-translate-typed-jsdoc-returns.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md), and
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md).

## Versioned consumer artifact

ADR-004 established the copied Python source/dist artifact boundary, and ADR-007
later governed release publication of those Python artifacts.  ADR-012 defers a
JavaScript consumer-artifact and release contract until corresponding behavior is
defined and tested.  ADR-018 establishes integration evidence only, while ADR-019
adds a checked-in consumer configuration fragment for yields without declaring a
versioned release artifact.  ADR-020 adds no consumer artifact because its native
forms require no generated compatibility configuration.  See
[ADR-004](adr/ADR-004-build-and-release-versioned-filter.md),
[ADR-007](adr/ADR-007-publish-and-canary-exact-release-artifacts.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md), and
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md).

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
evidence for native-compatible `@deprecated` and `@see` forms.  See
[ADR-005](adr/ADR-005-use-small-behavior-focused-fixtures.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md),
[ADR-014](adr/ADR-014-translate-optional-jsdoc-parameters.md),
[ADR-016](adr/ADR-016-translate-typed-jsdoc-returns.md),
[ADR-017](adr/ADR-017-translate-typed-jsdoc-throws.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md), and
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md).

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
rewrites.  See
[ADR-006](adr/ADR-006-adopt-sibling-build-test-and-documentation-infrastructure.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-015](adr/ADR-015-restore-project-self-documentation.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md), and
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md).

## Release publication and downstream pinning

ADR-007 governs publication and downstream pinning for the copied Python release
artifact.  ADR-012 defers any equivalent JavaScript release interface; no
`javascript-doxygen` consumer artifact should be treated as published or stable
until a later accepted decision establishes that contract.  ADR-015 restores only
project reference-documentation publication, ADR-018 restores only integration
testing, ADR-019 introduces a checked-in alias fragment without promoting the
filter or configuration to a released artifact, and ADR-020 introduces no new
release surface.  See
[ADR-007](adr/ADR-007-publish-and-canary-exact-release-artifacts.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-015](adr/ADR-015-restore-project-self-documentation.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md), and
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md).

## Scenario-level program regressions

ADR-008 added larger Python program regressions alongside focused fixtures.  Those
fixtures remain migration reference material.  ADR-012 governs the focused
JavaScript TAP suite, while ADR-018 adds targeted downstream integration fixtures
rather than establishing a broad scenario-level JavaScript regression suite.
ADR-019 adds a focused generator integration fixture for yields, and ADR-020 adds
a focused native-tag fixture without broadening that scope.  See
[ADR-008](adr/ADR-008-add-scenario-level-program-regressions.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md), and
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md).

## Standards-conforming docstring recognition

ADR-009 expanded the copied Python docstring recognition boundary.  ADR-012 does
not carry those Python-specific recognition rules into JavaScript.  ADR-013 adds a
separate JavaScript recognition boundary for required simple JSDoc parameters,
ADR-014 extends that boundary to bracketed simple optional parameters, ADR-016
adds a separate recognition boundary for canonical typed `@returns` records,
ADR-017 adds a typed-and-described `@throws` boundary, and ADR-019 adds a canonical
typed-and-described `@yields` boundary while leaving unsupported yields forms
unchanged.  ADR-020 does not add a parser recognition rule for `@deprecated` or
`@see`; it governs evidence-backed unchanged pass-through for those compatible
forms.  ADR-018 tests downstream Doxygen interpretation without widening source
semantics.  See
[ADR-009](adr/ADR-009-expand-standards-conforming-docstring-recognition.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md),
[ADR-014](adr/ADR-014-translate-optional-jsdoc-parameters.md),
[ADR-016](adr/ADR-016-translate-typed-jsdoc-returns.md),
[ADR-017](adr/ADR-017-translate-typed-jsdoc-throws.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md), and
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md).

## Unannotated type fields

ADR-010 translates copied Python `:type name:` and `:rtype:` fields into dedicated
Doxygen paragraphs.  ADR-012 does not adopt an equivalent JavaScript type-field
translation.  ADR-013 and ADR-014 preserve JSDoc parameter type expressions as
visible prose, ADR-016 extends that strategy to canonical return type expressions,
ADR-017 uses Doxygen's native exception-object slot for canonical exception types,
and ADR-019 preserves canonical yield types as visible `Type:` prose within the
alias-backed `Yields` paragraph; none establishes a general JavaScript Doxygen
type-field contract.  ADR-018 verifies selected resulting structures without
adding a general type-field translation, and ADR-020 does not alter type handling.
See [ADR-010](adr/ADR-010-translate-unannotated-type-fields.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
[ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md),
[ADR-014](adr/ADR-014-translate-optional-jsdoc-parameters.md),
[ADR-016](adr/ADR-016-translate-typed-jsdoc-returns.md),
[ADR-017](adr/ADR-017-translate-typed-jsdoc-throws.md),
[ADR-018](adr/ADR-018-enable-javascript-doxygen-integration-testing.md),
[ADR-019](adr/ADR-019-translate-typed-jsdoc-yields-with-alias.md), and
[ADR-020](adr/ADR-020-preserve-native-compatible-jsdoc-tags.md).
