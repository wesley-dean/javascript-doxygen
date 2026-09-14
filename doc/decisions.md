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
portable AWK implementations.  Python-specific documentation and release
workflows are deferred rather than satisfied with no-op compatibility targets,
and copied Python decisions remain migration history where ADR-012 supersedes
their language-specific contracts.  See
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md).

## Required JSDoc parameter translation

ADR-013 adds the first structured JavaScript documentation translation.  Canonical
required parameters written as `@param {Type} name - Description.` are rewritten
at the Doxygen boundary to a line-preserving representation with the parameter
name first and the maintained JSDoc type retained as visible prose.  The first
recognition boundary is intentionally narrow: unsupported forms, including
optional/defaulted parameters, remain unchanged and visible.  See
[ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md).

## Capability scope and epistemic honesty

The project distinguishes implemented behavior from planned behavior and makes
capability claims only when evidence supports them.  ADR-012 established the
initial pass-through baseline, while ADR-013 adds only the tested canonical
required-parameter translation and retains visible pass-through for unsupported
forms.  Broader JSDoc translation and Doxygen integration remain deferred until
separately governed and proven.  See
[ADR-000](adr/ADR-000-capability-scope-and-epistemic-honesty.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
and [ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md).

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
translation for canonical required `@param` records while preserving one output
record per input record.  See
[ADR-002](adr/ADR-002-preserve-python-and-translate-docstrings.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
and [ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md).

## Yields translation

ADR-003 governs the copied Python `:yields:` representation as a dedicated
Doxygen `Yields` paragraph.  ADR-012 does not adopt that language-specific
translation for JavaScript; the decision remains migration history until a
JavaScript-specific contract is accepted.  See
[ADR-003](adr/ADR-003-define-yields-translation.md) and
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md).

## Versioned consumer artifact

ADR-004 established the copied Python source/dist artifact boundary, and ADR-007
later governed release publication of those Python artifacts.  ADR-012 defers a
JavaScript consumer-artifact and release contract until corresponding behavior is
defined and tested.  See
[ADR-004](adr/ADR-004-build-and-release-versioned-filter.md),
[ADR-007](adr/ADR-007-publish-and-canary-exact-release-artifacts.md), and
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md).

## Behavior-focused fixtures

ADR-005 established the value of small behavior-focused fixtures.  ADR-012 keeps
that principle while replacing the copied Python fixture paths for maintained
JavaScript behavior with `test/fixtures/` and `test/expected/`, plus TAP output
from `test/run-tests.sh`.  ADR-013 extends that suite with focused supported and
unsupported JSDoc parameter cases, while ADR-008 remains historical support for
supplementary scenario-level coverage.  See
[ADR-005](adr/ADR-005-use-small-behavior-focused-fixtures.md),
[ADR-008](adr/ADR-008-add-scenario-level-program-regressions.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
and [ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md).

## Shared project infrastructure

ADR-006 directs reuse of coherent sibling-project infrastructure rather than
mechanical parity.  ADR-012 applies that principle to the JavaScript bootstrap by
retaining portable-AWK testing while explicitly deferring inherited Python-only
documentation and release automation.  See
[ADR-006](adr/ADR-006-adopt-sibling-build-test-and-documentation-infrastructure.md)
and
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md).

## Release publication and downstream pinning

ADR-007 governs publication and downstream pinning for the copied Python release
artifact.  ADR-012 defers any equivalent JavaScript release interface; no
`javascript-doxygen` consumer artifact should be treated as published or stable
until a later accepted decision establishes that contract.  See
[ADR-007](adr/ADR-007-publish-and-canary-exact-release-artifacts.md) and
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md).

## Scenario-level program regressions

ADR-008 added larger Python program regressions alongside focused fixtures.  Those
fixtures remain migration reference material.  ADR-012 currently governs only the
focused JavaScript TAP suite and does not yet establish scenario-level JavaScript
coverage.  See
[ADR-008](adr/ADR-008-add-scenario-level-program-regressions.md) and
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md).

## Standards-conforming docstring recognition

ADR-009 expanded the copied Python docstring recognition boundary.  ADR-012 does
not carry those Python-specific recognition rules into JavaScript.  ADR-013 adds a
separate, narrowly governed JavaScript recognition boundary for canonical required
JSDoc `@param` records while leaving unsupported JSDoc forms unchanged.  See
[ADR-009](adr/ADR-009-expand-standards-conforming-docstring-recognition.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
and [ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md).

## Unannotated type fields

ADR-010 translates copied Python `:type name:` and `:rtype:` fields into dedicated
Doxygen paragraphs.  ADR-012 does not adopt an equivalent JavaScript type-field
translation.  ADR-013 preserves the JSDoc type expression as visible prose for its
required-parameter translation, but it does not establish a general JavaScript
Doxygen type-field contract.  See
[ADR-010](adr/ADR-010-translate-unannotated-type-fields.md),
[ADR-012](adr/ADR-012-bootstrap-javascript-filter-and-tap-regression-contract.md),
and [ADR-013](adr/ADR-013-translate-required-jsdoc-parameters.md).
