# ADR-019: Translate Typed JSDoc Yields with a Doxygen Alias

Date: 2026-09-14

## Status

Accepted

## Context

The shared JavaScript documentation standard defines `@yields` as the maintained
source contract for values produced by generator functions.  Generator yields are
semantically distinct from an ordinary function return and must not be represented
as return documentation merely because Doxygen has a native return command.

ADR-018 establishes an executable JavaScript/Doxygen integration boundary and
makes physical line preservation an important compatibility property.  Doxygen
associates filtered input with source locations and source-browser anchors, so an
input filter should not add or remove physical source lines.

The copied Python project previously represented yields as a dedicated Doxygen
`Yields` paragraph by emitting an additional physical output line.  That
representation preserved generator semantics, but its line expansion conflicts
with the JavaScript project's now-tested line-correspondence requirement.

Doxygen has no native `@yields` command.  Doxygen does, however, support custom
commands through `ALIASES`, and an alias value may contain `^^` to introduce a
logical newline during Doxygen parsing without requiring the input filter to add a
physical source line.

A JavaScript-specific yields contract therefore needs to preserve all of the
following properties:

- maintained source remains canonical JSDoc;
- generator output is not misrepresented as an ordinary return;
- the filter preserves one physical output line for every physical input line;
- Doxygen renders a distinct `Yields` paragraph; and
- the consumer-side configuration required for that representation is explicit,
  inspectable, and integration-tested.

## Decision

The filter SHALL support the canonical maintained-source form:

```text
@yields {Type} Description.
```

inside the same conservatively recognized multi-line JSDoc blocks used by the
other governed translations.

A supported record SHALL be translated on the same physical line to:

```text
@jsyields Type: Type. Description.
```

The maintained JSDoc type expression SHALL be preserved textually without
validation, normalization, inference, or JavaScript semantic interpretation.
The description SHALL remain non-empty.

`@jsyields` is a generated Doxygen-facing command.  It is not a maintained-source
JSDoc tag and MUST NOT be introduced into maintained JavaScript by authors.

The repository SHALL maintain the consumer-side Doxygen configuration fragment:

```text
doxygen-javascript.conf
```

with the governed alias:

```text
ALIASES += jsyields="@par Yields^^"
```

Consumers that process filtered output containing translated `@yields` records
SHALL load an equivalent alias definition.  The checked-in fragment is the
repository's canonical representation of that requirement.

The alias SHALL introduce the logical paragraph break inside Doxygen rather than
the filter introducing an additional physical source line.  The filter SHALL
continue to emit exactly one physical output record for each physical input
record.

The TAP regression harness SHALL verify physical line-count preservation for every
fixture, not only yields fixtures.  This turns line correspondence into executable
evidence shared by all current and future translation behavior.

The JavaScript/Doxygen integration suite SHALL load the checked-in consumer
configuration fragment and SHALL verify that a translated yields record produces a
dedicated `Yields` paragraph containing the documented type and description.  The
integration fixture SHALL also retain a source-location assertion so alias
expansion cannot silently become evidence for physical line drift.

The first accepted yields grammar does not include description-only `@yields`,
type-only `@yields {Type}`, continuation records, one-line JSDoc blocks, or
malformed/ambiguous yields syntax.  Unsupported forms SHALL remain visible and
unchanged.

## Alternatives Considered

### Map yields to `@returns`

This was rejected because generator yields and ordinary function returns are
different caller-visible contracts.  A generator may yield many values over time
and may also have a final return value.  Collapsing those concepts would make the
generated documentation semantically false.

### Emit a two-line `@par Yields` representation

This is the representation used by the copied Python project.  It was rejected for
JavaScript because adding a physical line in the input filter breaks the
one-input-line-to-one-output-line correspondence protected by ADR-018 and can
shift Doxygen source locations and source-browser anchors.

### Emit `@par Yields` and the description on one physical line

This was rejected because the desired paragraph representation requires a logical
break between the paragraph heading and its body.  Encoding both parts directly on
one filtered line does not provide the same reliable generated structure.

### Use a Doxygen note, remark, or warning section

This was rejected because yields are part of the function's ordinary generator
contract, not an advisory note, implementation remark, or warning.

### Use `@xrefitem`

This was rejected because cross-referenced list semantics are unnecessary for
per-function generator output and would create unrelated generated-page behavior.

### Keep `@yields` unsupported

This remained valid while downstream Doxygen behavior had not been exercised.
ADR-018 now supplies an integration surface, and Doxygen aliases provide a
line-preserving representation that can be tested end to end, so permanent
pass-through is no longer preferable.

### Require maintainers to write `@jsyields`

This was rejected because the shared JavaScript standard establishes idiomatic
JSDoc as maintained source.  Doxygen-specific compatibility belongs at the filter
and consumer-configuration boundary rather than in source comments.

## Consequences

Generator output receives a distinct Doxygen-rendered `Yields` paragraph while
maintained JavaScript remains standard JSDoc.

The filter retains physical line correspondence.  The logical newline required by
Doxygen is introduced only during alias expansion.

Supporting yields introduces the first JavaScript translation whose complete
Doxygen representation depends on a repository-defined consumer configuration
fragment.  Consumers using translated yields must load the `jsyields` alias or an
exactly equivalent definition.  The dependency is explicit rather than hidden in
filter behavior.

The TAP suite gains a global physical-line-count invariant.  Future translation
work that adds or removes physical lines will fail existing regression tests and
will require an explicit architectural decision rather than accidental drift.

The Doxygen integration suite becomes responsible for proving both the rendered
`Yields` structure and continued source-location correspondence.

This decision does not establish a released consumer artifact, semantic-version
contract, or release publication workflow.  Those remain deferred until governed
separately.

## Expected Outcomes

Given maintained source containing:

```text
@yields {Record} Validated records in source order.
```

the filter emits exactly one corresponding physical line:

```text
@jsyields Type: Record. Validated records in source order.
```

With `doxygen-javascript.conf` loaded, Doxygen renders a dedicated `Yields`
paragraph containing both `Type: Record.` and the maintained description.

`make test AWK_BIN=mawk` and `make test AWK_BIN=gawk` continue to prove textual
translation and physical line preservation.  `make test-doxygen` proves that the
alias-backed representation is interpreted by Doxygen as intended.

## Compatibility and Migration

The maintained JSDoc source contract remains backward-compatible: authors continue
to write standard `@yields` documentation.

Existing Doxygen consumers that do not document generator yields are unaffected.
A consumer that begins processing translated yields must load the governed alias
configuration.  Until a released consumer package is defined, consumers should
copy or include `doxygen-javascript.conf` from the same repository revision as the
filter source they use.

The copied Python yields ADR remains historical reference only.  This decision is
the governing JavaScript-specific representation and deliberately does not adopt
the Python project's physical-line expansion.

## Related Decisions

- ADR-000 governs capability claims and executable evidence.
- ADR-003 records the historical copied Python yields representation.
- ADR-005 establishes behavior-focused fixture evidence.
- ADR-012 establishes the JavaScript filter and TAP regression boundary.
- ADR-015 separates repository self-documentation from JavaScript/Doxygen
  integration.
- ADR-016 governs canonical typed return translation and keeps yields semantically
  separate from returns.
- ADR-018 establishes JavaScript/Doxygen integration testing and physical-line
  preservation as an integration concern.
