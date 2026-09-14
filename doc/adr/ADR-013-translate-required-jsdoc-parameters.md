# ADR-013: Translate Canonical Required JSDoc Parameters

Date: 2026-09-14

## Status

Accepted

## Context

ADR-012 established `doxygen-javascript.awk` as the maintained JavaScript filter and deliberately limited the bootstrap milestone to source pass-through.  The next useful increment is the first structured JSDoc translation.

This repository now adopts `coding_standards@v1.0.6`, which includes the canonical JavaScript documentation standard.  That standard defines the maintained required-parameter form as:

```text
@param {Type} name - Description.
```

Doxygen's `@param` grammar expects the parameter name immediately after the command.  JSDoc places a braced type expression before the name.  The filter therefore needs to move the parameter name into Doxygen's expected position while keeping the maintained JSDoc type visible in the generated representation.

## Decision

`doxygen-javascript.awk` SHALL translate canonical required parameter records of the form:

```text
@param {Type} name - Description.
```

into a line-preserving Doxygen-facing representation equivalent to:

```text
@param name Description. Type: Type.
```

The maintained JavaScript source remains unchanged.  The generated representation is derivative and exists only at the Doxygen boundary.

The first implementation recognizes only multi-line JSDoc blocks whose `/**` opener and `*/` closer appear on otherwise blank documentation lines.  Inside those blocks, the supported parameter name must be a simple JavaScript identifier matching letters, digits after the first character, underscore, or dollar sign.

The type expression is preserved textually from inside the outer braces.  The filter does not validate or interpret the type expression.

The translation preserves one output record for every input record.

Unsupported parameter forms remain unchanged.  In particular, this first increment does not translate:

- optional parameters such as `[name]`;
- defaulted optional parameters such as `[name=value]`;
- dotted property names;
- rest-parameter syntax;
- destructured parameter documentation;
- one-line JSDoc blocks;
- continuation lines requiring additional association logic; or
- tags other than `@param`.

The existing TAP harness includes focused fixtures proving both the supported required-parameter translation and visible pass-through of an unsupported optional/defaulted parameter.

## Alternatives Considered

### Drop the JSDoc type

Translating only to `@param name Description.` was rejected because it would discard maintained source information that may be useful in generated reference documentation.

### Emit a second line for the type

A dedicated type paragraph was rejected for the first increment because it would increase physical line count and complicate source correspondence before there is evidence that a multi-line representation is necessary.

### Parse JavaScript signatures to validate the parameter

This was rejected because the filter is a documentation translator, not a JavaScript parser or semantic validator.  Signature/documentation agreement belongs to JavaScript-native tooling and repository policy.

### Support optional and complex parameters immediately

This was rejected because the project is intentionally growing one behavior at a time.  A narrow first grammar makes the recognition boundary inspectable and gives later forms their own focused fixtures and decisions.

## Consequences

The project gains its first real JSDoc translation while retaining line-preserving output and a narrow parser boundary.

Type information remains visible in generated Doxygen-facing prose, although Doxygen does not receive it as a separately typed parameter field.

Valid JSDoc constructs outside the implemented subset remain visible unchanged.  That is an explicit false-negative behavior rather than accidental partial parsing.

## Expected Outcomes

The regression suite reports three passing TAP assertions under both `mawk` and GNU awk:

1. ordinary JavaScript passes through unchanged;
2. a canonical required JSDoc parameter is translated; and
3. an unsupported optional/defaulted JSDoc parameter remains unchanged.

## Related Decisions

- ADR-000 governs capability scope and epistemic honesty.
- ADR-005 established behavior-focused fixtures.
- ADR-011 governs adoption of the shared coding standards, including the JavaScript documentation standard in `coding_standards@v1.0.6`.
- ADR-012 established the JavaScript filter, TAP harness, and pass-through bootstrap boundary.
