# ADR-012: Bootstrap the JavaScript filter and TAP regression contract

Date: 2026-09-14

## Status

Accepted

## Context

`javascript-doxygen` was initialized from the contents of `python-doxygen` so the
new project could reuse established repository infrastructure, governance patterns,
and documentation tooling.  That copy also brought Python-specific implementation,
tests, workflows, release assumptions, and accepted ADRs into a repository whose
intended maintained language boundary is JavaScript.

The project is not yet able to translate JSDoc into a Doxygen-facing
representation.  Claiming that capability before executable evidence exists would
conflict with ADR-000's requirement that capability claims follow demonstrated
behavior.

The first useful milestone therefore needs to establish a maintained JavaScript
filter, a fixture convention, a deterministic regression harness, and green CI
without inventing unsupported documentation transformations.  The test layout
should also provide a stable place for each future JSDoc transformation to gain a
small behavior-focused regression.

The desired test contract uses `test/fixtures/` for source inputs,
`test/expected/` for golden filtered output, and Test Anything Protocol (TAP)
output from the regression harness.  This differs from the copied Python layout
under `tests/python/`, so the JavaScript project requires an explicit local
decision rather than silently inheriting the Python path conventions.

The copied Python workflows also expect build, checksum, Doxygen integration,
documentation canary, and release interfaces that the JavaScript project has not
yet established.  Adding no-op targets merely to satisfy those workflows would
create false evidence of capabilities that do not exist.

## Decision

The maintained JavaScript filter SHALL be `doxygen-javascript.awk`.

For the bootstrap milestone, the filter SHALL perform only pass-through behavior:
each newline-terminated JavaScript source record read by AWK is written to STDOUT
without documentation translation.  This behavior exists to establish the filter
boundary and regression infrastructure; it is not a claim of JSDoc compatibility.

Small JavaScript regression fixtures SHALL live under:

```text
test/fixtures/
```

Golden filtered output SHALL live under:

```text
test/expected/
```

The regression runner SHALL be:

```text
test/run-tests.sh
```

The runner SHALL emit TAP version 13 output.  Each behavior claim added to the
filter SHOULD have a focused fixture and expected-output pair unless another test
surface is better suited to the behavior being verified.

`make test` SHALL be the canonical bootstrap regression entry point.  CI SHALL run
that target with at least `mawk` and GNU awk so the project's portable-AWK floor
is exercised from the beginning.

The first regression SHALL prove only that representative ordinary JavaScript is
preserved by the bootstrap filter.  Future JSDoc translations SHALL be added one
behavior at a time with corresponding executable evidence.

The inherited Python documentation canary and semantic-version release automation
SHALL NOT run automatically while they still describe Python-specific artifacts
and integration behavior.  They SHALL be visibly marked deferred until later ADRs
establish JavaScript-specific documentation-generation and release-artifact
contracts.  The project SHALL NOT add fake compatibility targets or publish copied
Python artifacts merely to keep inherited workflows green.

The existing copied Python implementation, tests, documentation, and ADRs MAY
remain temporarily as reference material during migration.  They MUST NOT be
interpreted as current JavaScript capability claims.  This ADR supersedes copied
Python-specific decisions where they conflict with the following current
JavaScript contracts:

- the maintained filter is `doxygen-javascript.awk`;
- JavaScript behavior-focused fixtures live beneath `test/fixtures/`;
- expected filtered output lives beneath `test/expected/`;
- the JavaScript regression harness emits TAP;
- `make test` currently validates maintained-source pass-through behavior only;
- automatic Python-specific documentation canaries are deferred; and
- automatic Python-specific release publication is deferred.

Copied decisions that express language-independent engineering principles remain
useful where they do not conflict with this ADR.  In particular, the project
retains the principles of narrow capability claims, behavior-focused fixtures,
portable AWK, reviewable infrastructure, and evidence before release claims.

## Alternatives Considered

### Translate JSDoc immediately

Beginning with `@param`, `@returns`, or other JSDoc transformations was rejected
for the bootstrap milestone because it would combine test-harness design with a
new documentation-translation contract.  Establishing a passing pass-through
baseline first makes later transformations easier to isolate and review.

### Keep the copied Python test layout

Retaining `tests/python/fixtures/` and `tests/python/expected/` was rejected
because those paths describe the wrong maintained language and do not match the
chosen JavaScript test organization.  A clean JavaScript-specific layout also
makes future fixtures easier to identify.

### Emit ad hoc human-readable test output

Plain status messages were rejected in favor of TAP because TAP is stable,
machine-readable, human-readable, and easy to consume from shell-oriented
workflows without introducing a larger testing framework.

### Add no-op Make targets for inherited workflows

Creating placeholder `build`, `checksums`, `test-doxygen`, `deps-docs`, or release
targets was rejected because successful no-op targets would make unsupported
capabilities appear implemented.

### Leave inherited Python release automation active

This was rejected because the copied workflow publishes `doxygen-python.awk` and
its checksum.  Publishing those artifacts from `javascript-doxygen` would create
an incorrect downstream interface and an invalid project release history.

## Consequences

The project gains a minimal maintained JavaScript filter and a green regression
contract before implementing JSDoc translation.

The first filter is intentionally trivial.  Passing tests demonstrate only the
pass-through behavior exercised by the fixture; they do not demonstrate JSDoc
translation or Doxygen integration.

Future filter work can add one fixture and one expected output per supported JSDoc
behavior, allowing the executable support boundary to grow incrementally.

The copied Python tree remains visibly transitional.  Subsequent work should
remove, replace, or adapt Python-specific files as JavaScript-specific governance
and implementation become available.

Documentation generation, Doxygen integration testing, distribution artifacts,
checksums, semantic-version releases, and release canaries remain deferred.  Each
should be re-enabled only after its JavaScript-specific contract is defined and
tested.

## Expected Outcomes

The immediate expected outcomes are:

- `doxygen-javascript.awk` exists as the maintained filter;
- `test/fixtures/pass-through.js` and `test/expected/pass-through.js` establish
  the golden-fixture convention;
- `test/run-tests.sh` emits one passing TAP test for the bootstrap behavior;
- `make test AWK_BIN=mawk` and `make test AWK_BIN=gawk` exercise the same suite;
- pull-request CI tests only behavior the project actually implements; and
- inherited Python publication workflows cannot create misleading JavaScript
  project releases.

## Compatibility and Migration

This decision intentionally changes the project away from the copied
`python-doxygen` interfaces.  Consumers SHOULD NOT depend on any
`javascript-doxygen` artifact until a later accepted decision establishes a
release interface.

No compatibility promise is made for the copied `doxygen-python.awk`,
`tests/python/`, or Python-specific workflow interfaces in this repository.
Their presence is transitional rather than contractual.

## Related Decisions

- ADR-000 governs capability claims and epistemic honesty.
- ADR-004 established the copied source/dist concept; its Python-specific artifact
  names are superseded here until a JavaScript release contract is established.
- ADR-005 established the value of small behavior-focused fixtures; this ADR
  replaces its Python-specific fixture paths for maintained JavaScript behavior.
- ADR-006 established reusable sibling infrastructure principles; this ADR applies
  those principles selectively rather than preserving Python mechanics blindly.
- ADR-007 governs the copied Python release boundary; automatic application of
  that Python artifact contract is deferred for this project.
- ADR-011 governs the imported shared coding standards snapshot.
