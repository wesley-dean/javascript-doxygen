# ADR-024: Preserve Canonical JSDoc Type Annotations with a Consumer Alias

Date: 2026-09-14

## Status

Accepted

## Context

The shared JavaScript documentation standard permits `@type` when documenting the
type of a value, property, constant, or other symbol for which a type expression is
part of the maintained contract.

Canonical maintained source therefore uses JSDoc such as:

```text
@type {number}
```

Unlike `@param`, `@returns`, and `@throws`, Doxygen does not provide a native
special command named `@type`.  An unknown command would otherwise be treated as
ordinary text, so the maintained JSDoc syntax would not receive the structured
presentation expected from the surrounding documentation contract.

One possible approach would be to translate JSDoc `@type` records inside
`doxygen-javascript.awk`.  That would require the filter to recognize and rewrite a
syntax that Doxygen can already accommodate through its documented `ALIASES`
mechanism.  More importantly, parsing the type expression in the AWK filter would
unnecessarily expose the filter to the breadth of JSDoc/Closure-style type syntax,
including unions, generics, nested expressions, record types, callbacks, and
punctuation that the project otherwise preserves textually rather than interprets.

Doxygen custom aliases can define commands which are not built in.  A simple alias
performs command substitution while leaving following source text in place.  It can
also introduce a logical newline using `^^` without changing the physical number
of lines produced by the input filter.

This allows canonical maintained JSDoc to remain completely unchanged at the
filter boundary while the Doxygen consumer configuration supplies presentation
semantics.

The repository's integration suite exercised the form:

```javascript
/**
 * Number of retry attempts before failure.
 *
 * @type {number}
 */
const retryLimit = 3;
```

through Doxygen 1.9.8 under both `mawk` and GNU awk.  The generated XML contains
the documented `retryLimit` symbol together with a `Type` paragraph whose body
retains `{number}`.  The TAP fixture simultaneously proves byte-for-byte filter
pass-through and physical line-count preservation.

## Decision

The repository SHALL support the canonical maintained-source form:

```text
@type {Type}
```

as an evidence-backed consumer-configuration capability.

`doxygen-javascript.awk` SHALL NOT rewrite the supported `@type` record.  The filter
SHALL preserve that maintained JSDoc line unchanged.

The checked-in Doxygen consumer configuration SHALL define an alias equivalent to:

```text
ALIASES += type="@par Type^^"
```

The alias SHALL cause Doxygen to render the text following `@type` as the body of a
dedicated `Type` paragraph attached to the symbol documented by the surrounding
comment block.

The maintained JSDoc type expression, including its braces, SHALL remain textual
documentation data.  The filter and alias SHALL NOT validate, normalize, infer,
resolve, or otherwise interpret the type expression.

The alias is a presentation boundary, not a type-system integration.  A generated
`Type` paragraph SHALL NOT be claimed as a native Doxygen semantic type, a parsed
JavaScript type, or evidence that Doxygen understands the JSDoc type expression.

The repository SHALL claim support only for canonical, standards-conforming
maintained `@type {Type}` records covered by governing documentation and executable
evidence.  The consumer alias does not act as a JSDoc validator; malformed or
noncanonical `@type` text may still be processed by Doxygen because aliases are
configured at the consumer boundary.

This decision does not establish automatic linking from type expressions to
ADR-021 virtual typedef pages or ADR-023 callback pages.  Type names remain visible
text unless a later accepted decision explicitly governs cross-reference rewriting.

This decision does not establish JavaScript type inference, TypeScript support,
TSDoc support, runtime validation, or a broader type-expression parser.

All existing one-input-line/one-output-line guarantees remain unchanged because the
filter performs no transformation for this capability.

## Alternatives Considered

### Translate `@type` to a generated `@jstype` command in AWK

Rejected.  A generated command would add translator code without providing a
semantic benefit.  Doxygen can define `@type` itself as a custom command, so the
maintained JSDoc record can remain byte-preserved.

### Translate `@type` to Doxygen `@var`

Rejected.  Doxygen `@var` is a structural command describing a variable declaration
and may require declaration information or a symbol name.  JSDoc `@type` documents
the type of the symbol already associated with the surrounding block.  Mapping it
to `@var` would force the filter to parse or duplicate source-level symbol identity
and would overstate Doxygen semantic understanding.

### Parse the type expression and remove JSDoc braces

Rejected.  The project deliberately treats maintained type expressions as textual
documentation data.  Parsing them would broaden the filter into a partial JSDoc
or JavaScript type parser and create an unnecessary compatibility surface.

### Convert recognized virtual typedef or callback names into Doxygen references

Rejected for this increment.  Automatic linking is useful but materially different
from preserving a type annotation.  It requires tokenization, name-resolution
rules, collision behavior, and decisions about compound type expressions.  Those
questions remain separately governed.

### Leave `@type` entirely unsupported

Rejected after executable evidence demonstrated that a zero-rewrite consumer alias
faithfully preserves the maintained text and produces useful symbol-local Doxygen
documentation under both supported AWK implementations.

## Consequences

Canonical `@type` becomes the first supported JSDoc capability whose implementation
lives entirely in the Doxygen consumer configuration rather than in the AWK
translator or Doxygen's native special-command set.

The maintained filter remains smaller and avoids a type-expression parsing surface.

Consumers that want supported `@type` rendering must load
`doxygen-javascript.conf` or an exactly equivalent alias definition.

The generated documentation presents an explicit `Type` paragraph while retaining
the original JSDoc expression verbatim.  Readers can see the maintained type
contract without the project pretending that Doxygen has interpreted it.

The distinction among supported behavior now includes at least three mechanisms:

- filter translation where JSDoc and Doxygen syntax differ materially;
- native-compatible pass-through where Doxygen already understands the maintained
  command; and
- consumer-alias pass-through where maintained JSDoc remains unchanged and Doxygen
  receives presentation semantics through checked-in configuration.

This distinction must remain visible in repository documentation so support is not
mistaken for AWK translation coverage.

## Expected Outcomes

For maintained source such as:

```javascript
/**
 * Number of retry attempts before failure.
 *
 * @type {number}
 */
const retryLimit = 3;
```

the filter output SHALL be byte-equivalent to the input for the documentation
record and SHALL preserve physical line count.

Doxygen configured with the governed alias SHALL create documentation for
`retryLimit` containing a `Type` paragraph whose body retains `{number}`.

The TAP suite SHALL include focused exact-pass-through evidence under both `mawk`
and GNU awk.

The Doxygen integration suite SHALL verify the alias definition, the documented
symbol, the `Type` paragraph, and retained type text under both supported AWK
implementations.

## Compatibility and Migration

Existing maintained source requires no migration because supported source remains
ordinary JSDoc.

Existing consumers that do not use `@type` are unaffected.

Consumers that want `@type` rendered through Doxygen must load the updated
`doxygen-javascript.conf` fragment or provide an exactly equivalent alias.

This decision adds no new generated JavaScript syntax, filter output syntax, page
label namespace, or runtime artifact.

The versioned consumer-artifact and release-publication boundary remains deferred.
Issue #17 separately tracks future build/distribution artifacts and does not change
this decision's source-documentation contract.

## Related Decisions

- ADR-000 governs capability claims and executable evidence.
- ADR-005 governs small behavior-focused fixtures.
- ADR-012 establishes visible pass-through for unsupported JavaScript documentation
  forms and the TAP regression boundary.
- ADR-018 establishes downstream JavaScript/Doxygen integration evidence and
  physical line correspondence as a compatibility concern.
- ADR-019 establishes consumer aliases as a line-preserving way to add logical
  Doxygen presentation structure.
- ADR-020 establishes evidence-backed pass-through where maintained JSDoc and
  Doxygen native commands are already compatible.
- ADR-021 and ADR-023 establish named virtual documentation entities whose names
  are not automatically resolved from type expressions by this decision.
