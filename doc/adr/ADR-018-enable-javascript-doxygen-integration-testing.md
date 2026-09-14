# ADR-018: Enable JavaScript/Doxygen Integration Testing

Date: 2026-09-14

## Status

Accepted

## Context

ADR-012 established the initial JavaScript filter and TAP regression boundary while
explicitly deferring JavaScript/Doxygen integration until the project had governed
translation behavior worth exercising.  ADR-013, ADR-014, ADR-016, and ADR-017 now
establish executable contracts for required and optional parameters, typed return
values, and typed exception documentation.

ADR-015 later restored repository self-documentation, but deliberately kept that
capability separate from exercising maintained JavaScript through
`doxygen-javascript.awk` and Doxygen.  The project therefore has strong filter-level
evidence without yet proving that the generated representation is consumed by
Doxygen as intended.

Current Doxygen supports an explicit JavaScript parser through
`EXTENSION_MAPPING = js=JavaScript`.  The project can therefore preserve JavaScript
as the parsed source language while using `doxygen-javascript.awk` only as the
input-filter documentation translation boundary.

Doxygen input filters are expected to preserve physical line count so source
locations and source-browser anchors remain aligned.  The currently accepted
JavaScript translations preserve one output record for every input record, making
them suitable for direct integration testing without changing that invariant.

## Decision

The repository SHALL maintain a JavaScript/Doxygen integration fixture beneath
`test/doxygen/` and SHALL expose `make test-doxygen` as the canonical integration
entry point.

The integration Doxyfile SHALL:

- parse `.js` input with Doxygen's JavaScript parser;
- apply `doxygen-javascript.awk` through `FILTER_PATTERNS`;
- generate XML for deterministic structural assertions;
- enable filtered source processing so the tested source-browser representation
  uses the same filter boundary; and
- write generated integration output beneath `test/doxygen/out/`, which SHALL
  remain untracked.

The integration fixture SHALL exercise representative forms already governed by
accepted JavaScript-specific ADRs.  Initial assertions SHALL establish that Doxygen
interprets the filtered representation as:

- named parameter documentation for required parameters;
- named parameter documentation retaining visible optional/default prose;
- return documentation in a Doxygen return section; and
- exception documentation in a Doxygen exception parameter list.

Assertions SHOULD target generated XML structure where practical rather than only
searching for source text that could appear in a source listing without having
been parsed semantically.

CI SHALL run the integration target under both `mawk` and GNU awk, preserving the
same portable-AWK floor as the TAP regression suite.  The ordinary `make test`
entry point SHALL remain the lightweight filter-level TAP suite; Doxygen
integration SHALL remain a separately named test surface so failures are easy to
classify.

This decision supersedes ADR-012 and ADR-015 only where they defer
JavaScript/Doxygen integration testing.  Generated consumer artifacts, checksums,
semantic-version releases, and release-artifact canaries remain deferred.

Successful integration tests demonstrate only the governed forms and Doxygen
configuration they exercise.  They MUST NOT be treated as evidence that arbitrary
JSDoc, arbitrary JavaScript syntax, or every Doxygen output format is supported.

## Alternatives Considered

### Continue relying only on golden filtered output

This was rejected because golden fixtures prove the filter's textual output, not
that Doxygen assigns the intended semantic structure to that output.

### Translate JavaScript into C or C++ before Doxygen

This was rejected because current Doxygen has a JavaScript parser and the project
intends to remain a documentation translator rather than a JavaScript source
transpiler.

### Fold Doxygen integration into every `make test` invocation

This was rejected because Doxygen is a materially heavier dependency than AWK and
a separate target provides clearer diagnostics while preserving a lightweight
local regression path.

### Test only one AWK implementation

This was rejected because the production filter's portability contract covers at
least `mawk` and GNU awk.  The Doxygen invocation should not create an untested
implementation-specific path.

### Assert only that expected words appear somewhere in XML

This was rejected where structural assertions are available because source-browser
listings can contain the same text without proving that Doxygen parsed a parameter,
return, or exception contract.

## Consequences

The repository gains executable evidence for the complete maintained-source to
filter to Doxygen path for currently governed documentation forms.

Future translation decisions can use this integration surface to validate
Doxygen-facing representations before those representations are accepted.

The line-preserving behavior of currently supported translations becomes an
important compatibility property of the integration boundary.  A future proposal
that adds or removes physical lines must explicitly account for Doxygen's source
location and anchor behavior rather than inheriting a representation from another
language project without validation.

Integration CI will take longer than the TAP-only suite because it installs and
runs Doxygen, but the additional cost is isolated in a separately named job.

## Expected Outcomes

A Doxygen-capable environment can run:

```sh
make test-doxygen AWK_BIN=mawk
make test-doxygen AWK_BIN=gawk
```

and obtain passing XML-structure assertions for the currently governed parameter,
return, and exception translations.

Pull requests will show distinct semantic-regression and Doxygen-integration jobs,
making it clear whether a failure belongs to the filter's textual behavior or to
the downstream Doxygen representation.

## Compatibility and Migration

This change adds a test capability and does not change the maintained-source JSDoc
contract or the filter's current output representation.

No consumer artifact or release interface is established by this decision.
Existing consumers, if any, should continue treating the repository as an
unreleased source project until a later accepted decision establishes a stable
artifact contract.

## Related Decisions

- ADR-000 governs capability claims and executable evidence.
- ADR-005 establishes behavior-focused regression evidence.
- ADR-006 governs selective reuse of sibling-project infrastructure.
- ADR-012 establishes the JavaScript filter and TAP regression boundary and is
  superseded here only for deferred JavaScript/Doxygen integration testing.
- ADR-013 governs required parameter translation.
- ADR-014 governs optional parameter translation.
- ADR-015 governs project self-documentation and remains authoritative for that
  separate capability.
- ADR-016 governs typed return translation.
- ADR-017 governs typed exception translation.
