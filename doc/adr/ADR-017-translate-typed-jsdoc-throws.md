# ADR-017: Translate Typed JSDoc Throws Records

Date: 2026-09-14

## Status

Accepted

## Context

The shared JavaScript documentation standard defines `@throws` as the maintained
source form for caller-visible exception and rejection contracts.  Its canonical
examples use a braced JSDoc type followed by explanatory prose:

```text
@throws {TypeError} If the supplied identifier is not a string.
```

JSDoc also permits description-only and type-only `@throws` records.  Those forms
are valid maintained JSDoc, but validity under the shared standard does not by
itself establish a `javascript-doxygen` translation contract.

Doxygen recognizes `@throws` as a native command and expects the exception object
immediately after the command, followed by the exception description.  The JSDoc
braces around the exception type therefore prevent the maintained source record
from already matching Doxygen's preferred command shape.

ADR-013 and ADR-014 established narrow parameter translation.  ADR-016 established
typed `@returns` translation while preserving the Doxygen-recognized command and
moving the JSDoc-specific type syntax into a Doxygen-friendly representation.
`@throws` is the next core contract tag whose canonical maintained-source syntax
can be translated without JavaScript semantic analysis.

## Decision

The filter SHALL translate the canonical typed-and-described JSDoc throws form:

```text
@throws {Type} Description.
```

to the line-preserving Doxygen-facing form:

```text
@throws Type Description.
```

The `@throws` command itself SHALL be preserved because Doxygen recognizes it
natively.  The filter SHALL remove only the JSDoc braces around the exception type
and SHALL preserve the exception type and description text otherwise unchanged.

The supported exception type SHALL be a compact, non-empty token containing no
whitespace and no closing brace.  The filter SHALL NOT interpret, validate,
normalize, infer, or resolve that type as JavaScript semantics.

The governed form SHALL require a non-empty description after the typed exception.
The following JSDoc-valid forms remain unsupported in this increment and SHALL
pass through visibly unchanged:

```text
@throws Description only.
@throws {TypeError}
```

Types containing whitespace, continuation records, one-line JSDoc blocks, and
ambiguous or malformed throws syntax SHALL also remain unchanged.

The filter SHALL continue to emit one output record for every input record.

## Recognition Boundary

Translation applies only inside the conservatively recognized multi-line JSDoc
blocks already governed by the repository.  A source record must match all of the
following conditions:

- the record is inside a supported JSDoc block;
- the tag is exactly `@throws`;
- a braced exception type immediately follows the tag;
- the exception type is compact and contains no whitespace;
- at least one whitespace character follows the closing brace; and
- a non-empty description follows the type.

A record outside that boundary is a visible false negative and remains unchanged.
This is preferred to speculative widening of the source grammar.

## Alternatives Considered

### Preserve the JSDoc record unchanged

This was rejected for the canonical typed-and-described form because Doxygen has a
native exception command whose expected argument order maps cleanly to the JSDoc
contract once the type braces are removed.

### Emit `@throws Description. Type: Type.`

This was rejected because it would discard Doxygen's native exception-object
argument.  Unlike `@returns`, the Doxygen `@throws` command has a dedicated first
argument for the exception object, so the maintained type can occupy that semantic
position directly.

### Translate every JSDoc-valid throws form now

This was rejected because description-only and type-only throws records have
different representation questions and are not required to establish the common
canonical contract.  They remain visible and can be governed separately if future
usage provides evidence that support is valuable.

### Parse or validate JavaScript exception types

This was rejected because the filter is a documentation translator, not a
JavaScript parser or type system.  Type correctness remains the responsibility of
maintained source, review, and JavaScript-native tooling.

## Consequences

Canonical typed exception documentation becomes consumable by Doxygen without
requiring maintainers to write parallel Doxygen-specific comments.

The generated representation differs minimally from maintained source: the JSDoc
braces are removed while the command, type text, description, indentation, and
record count remain stable.

Some valid JSDoc throws records continue to pass through unchanged.  This is an
intentional false-negative boundary rather than an implicit claim that those forms
are invalid source documentation.

## Expected Outcomes

A maintained source record such as:

```text
 * @throws {TypeError} If the identifier is not a string.
```

is emitted as:

```text
 * @throws TypeError If the identifier is not a string.
```

Description-only and type-only throws records remain byte-for-byte unchanged.
Regression fixtures protect both the supported translation and the unsupported
boundary under `mawk` and GNU awk.

## Related Decisions

- ADR-000 governs capability scope and epistemic honesty.
- ADR-012 establishes the JavaScript filter and TAP regression boundary.
- ADR-013 and ADR-014 govern parameter translation.
- ADR-015 separates project self-documentation from JavaScript/Doxygen integration.
- ADR-016 governs canonical typed return translation.
