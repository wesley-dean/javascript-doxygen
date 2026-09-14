# ADR-021: Represent Virtual JSDoc Typedefs as Related Pages

Date: 2026-09-14

## Status

Accepted

## Context

The shared JavaScript documentation standard defines JSDoc as the maintained
source of truth and explicitly permits named reusable documentation types through
`@typedef`.  A JSDoc typedef may describe a conceptual object shape or value that
has no dedicated runtime JavaScript class or declaration.  The maintained source
therefore needs a Doxygen representation that preserves the typedef as a named,
linkable documentation concept without inventing executable JavaScript.

ADR-018 established downstream JavaScript/Doxygen integration evidence.  ADR-019
then established physical line preservation as an explicit compatibility property
and demonstrated that Doxygen aliases can introduce logical documentation
structure without the input filter adding or removing source records.  ADR-020
established that native compatibility may be claimed only when downstream evidence
proves compatible syntax and semantics.

A native-compatibility probe was performed before choosing a representation.  On
the Ubuntu 24.04 CI environment, Doxygen 1.9.8 received canonical maintained JSDoc:

```text
@typedef {Object} User
```

unchanged through the filter.  Doxygen emitted the warning:

```text
documented symbol 'Object User' was not declared or defined
```

and generated no usable typedef entity in XML.  The source record appeared only in
the filtered source listing.  Native pass-through therefore fails the project's
evidence requirement and does not provide the named, linkable virtual type needed
by the maintained JSDoc contract.

Doxygen structural commands such as `@class`, `@struct`, `@interface`, `@fn`, and
native `@typedef` can produce named symbols, but using one of those commands would
claim a runtime or language declaration that does not exist.  That would alter the
meaning of the maintained documentation rather than translate it.

Doxygen related pages are explicitly intended for documentation that is not tied
to a specific class, file, or member.  A related page is named, navigable, and a
valid `@ref` target.  It therefore provides a Doxygen-native entity for a virtual
JSDoc type without asserting that the virtual type is an executable JavaScript
class, function, variable, or declaration.

Doxygen page labels have portability and case-sensitivity constraints that do not
match JavaScript identifiers directly.  The generated representation therefore
needs a deterministic internal label that distinguishes JavaScript case while
using only lowercase ASCII letters and digits.

## Decision

Canonical virtual typedef records written as:

```text
@typedef {Type} Name
```

SHALL be supported when `Name` is a simple JavaScript identifier matching:

```text
[A-Za-z_$][A-Za-z0-9_$]*
```

and the maintained type expression can be transported safely through the governed
Doxygen alias invocation.

The filter SHALL NOT emit a fake JavaScript declaration or map a JSDoc virtual type
to a Doxygen class, struct, interface, function, variable, or native typedef
symbol.

Instead, the filter SHALL translate the maintained typedef record to the generated
Doxygen-facing command:

```text
@jstypedef{Label||Name||Type}
```

on the same physical source line.

`@jstypedef` is derivative syntax only.  Maintainers SHALL continue to write
ordinary JSDoc `@typedef` records and SHALL NOT write `@jstypedef` in maintained
JavaScript.

The checked-in consumer configuration SHALL define an alias equivalent to:

```text
ALIASES += jstypedef{3||}="@page \1 \2^^@par JSDoc virtual type^^Base type: \3."
```

The alias SHALL create a Doxygen related page whose visible title is the exact
maintained typedef name.  The page SHALL retain the surrounding JSDoc prose from
the documentation block and SHALL present the maintained base type as visible
text.  Doxygen alias expansion may introduce logical line breaks, but the filter
itself SHALL preserve one physical output record for every input record.

The generated page label SHALL be deterministic, lowercase, alphanumeric, and
independent of Doxygen case-sensitive-name configuration.  The initial encoding
SHALL use the prefix:

```text
jsdocvirtualtype
```

followed by one token for every character in the JavaScript identifier:

- uppercase ASCII letters become `u` followed by the lowercase letter;
- lowercase ASCII letters become `l` followed by the same letter;
- digits become `d` followed by the digit;
- underscore becomes `n0`; and
- dollar sign becomes `s0`.

For example, `User` becomes:

```text
jsdocvirtualtypeuulslelr
```

The internal label is generated representation, not maintained-source API.
Consumers and integration tests may use it as a Doxygen `@ref` target, but source
authors should refer to the maintained JSDoc type name and should not be required
to know or duplicate the generated label.

The initial recognition boundary SHALL remain deliberately narrow.  Unsupported or
ambiguous typedef forms SHALL pass through visibly unchanged.  This includes at
least:

- missing explicit JSDoc type expressions;
- dotted or otherwise non-simple typedef names;
- continuation-based typedef declarations not covered by this decision; and
- type expressions containing the selected multi-character alias separator `||`.

This decision establishes the entity model for virtual typedefs only.  It does not
yet establish how `@property`, `@callback`, callback parameters, callback return
values, general `@type`, or automatic linking of every JSDoc type expression to a
virtual typedef page will be represented.  Those capabilities SHALL be added only
with focused governance and executable evidence.

## Alternatives Considered

### Preserve canonical JSDoc `@typedef` unchanged

This was tested and rejected.  Doxygen 1.9.8 interpreted `{Object} User` as a
documented declaration that did not exist, emitted a warning, and created no
usable typedef entity.

### Translate the virtual type to a Doxygen native typedef declaration

This was rejected because a JSDoc virtual typedef need not correspond to any
JavaScript declaration.  Producing a native typedef entity would imply source
semantics that are absent from the maintained program.

### Translate the virtual type to a Doxygen class, struct, or interface

This was rejected because those entities describe runtime or language-level
abstractions that a JSDoc object typedef does not necessarily represent.  The
result would be easy to navigate but semantically misleading.

### Synthesize JavaScript solely for Doxygen

This was rejected because the filter is a documentation translator, not a source
transpiler.  Fabricating declarations would make generated documentation depend on
invented executable structure and would violate the project's JavaScript-native
source boundary.

### Render typedefs only as anonymous prose paragraphs

This was rejected because named reusable JSDoc typedefs are intended to be reusable
documentation concepts.  Anonymous prose would preserve text while losing the
named, navigable, cross-referenceable identity required for this capability.

### Use raw maintained typedef names as Doxygen page labels

This was rejected because JavaScript identifier case and characters do not map
cleanly to Doxygen page-label portability constraints.  A deterministic encoded
label keeps generated identifiers portable while retaining the exact source name
as the visible page title.

### Add or remove physical lines in the filter

This was rejected under the ADR-018 and ADR-019 integration contract.  Doxygen
input filters are expected to preserve source-line correspondence.  Alias expansion
already provides the required logical structure without changing physical records.

## Consequences

Virtual JSDoc typedefs become first-class named documentation entities in Doxygen
without becoming fake JavaScript declarations.

Generated typedef pages appear among Doxygen related pages rather than among class
or language typedef indexes.  That placement is intentional: the entity is a
virtual documentation type, not an executable declaration.

Doxygen consumers that need virtual typedef support must load the checked-in
`doxygen-javascript.conf` fragment or an exactly equivalent alias definition.  This
extends the consumer-configuration contract already established for `@yields`.

Generated labels are stable for a given supported identifier under this decision,
but they remain derivative implementation details.  A future migration of label
encoding would require compatibility consideration for generated cross-references.

The filter remains line-preserving and does not need JavaScript semantic analysis,
type inference, or declaration synthesis.

Properties and callback contracts remain separate design problems.  The related-
page entity model gives those later decisions an honest parent concept without
prejudging their detailed representation.

## Expected Outcomes

For maintained source such as:

```javascript
/**
 * Represents a user record used by formatters.
 *
 * @typedef {Object} User
 */
```

the filter emits one generated record in place of the typedef line, Doxygen creates
a related page titled `User`, the surrounding prose remains attached to that page,
and the page presents `Object` as the documented base type.

The generated page can be addressed with Doxygen `@ref` using its deterministic
internal label.  Integration tests SHALL prove both page generation and successful
cross-reference resolution rather than relying only on filtered text.

The TAP suite SHALL continue proving exact filter output and physical line-count
preservation under both `mawk` and GNU awk.

## Compatibility and Migration

Existing governed parameter, return, exception, yield, deprecation, and see-also
behavior is unchanged.

Repositories that consume only previously supported forms need no configuration
change.  Repositories that adopt virtual typedef translation must load the updated
consumer configuration containing the `jstypedef` alias.

This decision does not establish a released consumer artifact or semantic-version
contract.  The repository remains governed by the existing deferred release
boundary until a later decision publishes stable artifacts.

## Related Decisions

- ADR-000 governs capability claims and executable evidence.
- ADR-005 governs focused behavior fixtures.
- ADR-012 establishes the JavaScript filter and visible unsupported behavior.
- ADR-018 establishes downstream JavaScript/Doxygen integration evidence and
  physical line correspondence as a compatibility concern.
- ADR-019 establishes alias-backed generated documentation while preserving
  physical line count.
- ADR-020 governs evidence-driven native compatibility and explains why matching
  command names alone are insufficient.
