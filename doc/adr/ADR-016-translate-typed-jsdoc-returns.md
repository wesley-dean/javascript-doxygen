# ADR-016: Translate Canonical Typed JSDoc Returns

Date: 2026-09-14

## Status

Accepted

## Context

ADR-013 and ADR-014 established line-preserving translation for canonical JSDoc
parameter forms while preserving maintained type information as visible
Doxygen-facing prose.  The next core JSDoc contract is the function return value.

The adopted JavaScript documentation standard defines the preferred maintained
source form as:

```text
@returns {Type} Description.
```

JSDoc also recognizes `@return` as a synonym, but the shared standard explicitly
prefers `@returns` for maintained source.  Doxygen recognizes `@returns` as an
alias of its return-value command, so the command name itself does not need to be
changed.  The compatibility problem is the JSDoc type expression placed before
the description.

## Decision

`doxygen-javascript.awk` SHALL translate canonical typed return records of the
form:

```text
@returns {Type} Description.
```

into a line-preserving Doxygen-facing representation equivalent to:

```text
@returns Description. Type: Type.
```

The maintained JavaScript source remains unchanged.  The generated representation
exists only at the Doxygen boundary.

The filter SHALL preserve the type expression textually from inside the outer
braces.  It SHALL NOT validate, normalize, infer, or interpret the type.

The supported record MUST contain a non-empty type expression and a non-empty
description on the same physical line.  The translation SHALL preserve one output
record for every input record.

This increment SHALL NOT translate:

- the singular JSDoc synonym `@return`;
- an untyped `@returns` record;
- a typed `@returns` record with no description;
- continuation lines requiring association with a prior return tag;
- one-line JSDoc blocks; or
- other return-like tags such as `@yields`.

Unsupported forms SHALL remain unchanged and visible.

The TAP suite SHALL include a positive typed-return fixture and an explicit
negative fixture proving that singular `@return` remains unchanged.

## Alternatives Considered

### Rewrite `@returns` to `@return`

This was rejected because Doxygen already recognizes `@returns`.  Rewriting the
command would add transformation without providing additional compatibility.

### Leave the JSDoc type in place

Passing `@returns {Type} Description.` through unchanged was rejected because the
braced type is JSDoc syntax rather than part of the human return-value
description.  Moving it to explicit `Type:` prose matches the representation
already established for supported parameters.

### Translate both `@returns` and `@return`

This was rejected for the current increment because the repository's adopted
source standard prefers `@returns`.  Supporting the synonym would widen the
maintained-source recognition boundary without a present need.

### Infer return types from JavaScript

This was rejected because the filter is a documentation translator, not a
JavaScript parser or type-inference engine.

## Consequences

The filter gains its first non-parameter JSDoc translation while retaining the
existing line-preserving and text-preserving architecture.

Return type information remains visible in generated documentation without being
interpreted as executable JavaScript semantics.

Valid JSDoc forms outside the accepted recognition boundary remain visible
unchanged rather than receiving speculative partial translation.

## Expected Outcomes

The regression suite reports seven passing TAP assertions under both `mawk` and
GNU awk.  The new assertions prove that a canonical typed `@returns` record is
translated and that the singular `@return` synonym remains unchanged.

## Related Decisions

- ADR-000 governs capability scope and epistemic honesty.
- ADR-005 established behavior-focused fixtures.
- ADR-011 governs adoption of the shared JavaScript documentation standard.
- ADR-012 established the JavaScript filter and TAP regression contract.
- ADR-013 established canonical required-parameter translation.
- ADR-014 established canonical optional-parameter translation.
- ADR-015 governs project self-documentation independently of JavaScript/Doxygen
  integration.
