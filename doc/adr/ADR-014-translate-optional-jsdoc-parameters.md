# ADR-014: Translate Optional JSDoc Parameters

Date: 2026-09-14

## Status

Accepted

## Context

ADR-013 established the first structured JavaScript documentation translation for canonical required parameters written as:

```text
@param {Type} name - Description.
```

The adopted JavaScript documentation standard also defines two maintained optional-parameter forms:

```text
@param {Type} [name] - Description.
@param {Type} [name=default] - Description.
```

The filter should support those forms without changing maintained JSDoc source, without adding source lines, and without interpreting JavaScript defaults or JSDoc type expressions.

Doxygen still expects the parameter name immediately after `@param`.  Optionality and documented defaults therefore need a visible derivative representation that preserves the maintained contract while moving the simple parameter identifier into Doxygen's expected position.

## Decision

`doxygen-javascript.awk` SHALL translate canonical optional parameter records with simple JavaScript identifiers.

An optional parameter without a documented default:

```text
@param {Type} [name] - Description.
```

SHALL become a line-preserving Doxygen-facing representation equivalent to:

```text
@param name Description. Type: Type. Optional.
```

An optional parameter with a documented default:

```text
@param {Type} [name=default] - Description.
```

SHALL become a line-preserving Doxygen-facing representation equivalent to:

```text
@param name Description. Type: Type. Optional. Default: default.
```

The maintained JavaScript source remains unchanged.  The generated representation exists only at the Doxygen boundary.

The supported parameter name SHALL remain a simple JavaScript identifier using letters, digits after the first character, underscore, or dollar sign.

The filter SHALL preserve the type expression textually from inside the outer braces.  For this increment, a documented default SHALL be a non-empty compact token containing neither whitespace nor a closing square bracket.  The filter SHALL preserve that default text exactly as written after the first equals sign and before the closing bracket.  The filter SHALL NOT evaluate, normalize, quote, type-check, or compare that default with executable JavaScript.

A defaulted optional token containing no text after the equals sign, whitespace within the default, or a closing square bracket within the default is unsupported in this increment.

The translation SHALL preserve one output record for every input record.

Unsupported parameter forms SHALL remain unchanged.  In particular, this decision does not add support for:

- dotted property names such as `options.name`;
- optional dotted property names;
- rest-parameter notation;
- destructured parameter documentation;
- one-line JSDoc blocks;
- continuation lines requiring association with a prior tag; or
- tags other than `@param`.

The TAP suite SHALL retain the required-parameter regression, translate both optional forms, and prove that unsupported property notation remains visible unchanged.

## Alternatives Considered

### Preserve the square brackets in the emitted parameter name

Emitting `@param [name] ...` was rejected because Doxygen expects the parameter name itself in the command's parameter-name position.  Optionality is instead preserved explicitly in prose.

### Drop optionality and default information

Translating optional forms exactly like required parameters was rejected because it would erase caller-visible contract information maintained in JSDoc.

### Interpret JavaScript default expressions

Evaluating or normalizing default values was rejected because the filter is a documentation translator rather than a JavaScript parser or evaluator.  The documented default is preserved textually.

### Support arbitrary default expressions immediately

Defaults containing whitespace or closing square brackets were rejected for this increment because they require a wider token grammar and additional fixtures.  Compact defaults cover the first useful cases while keeping the recognition boundary inspectable.

### Support property notation in the same increment

Dotted property names were rejected for this increment because they introduce a different name grammar and object-shape semantics.  Keeping them unchanged makes the support boundary explicit and separately governable.

## Consequences

The filter now supports the three canonical simple-parameter forms established by the adopted JavaScript documentation standard: required, optional, and optional with a compact documented default.

Optionality and supported defaults remain visible in generated documentation without changing physical line correspondence.

The emitted `Optional.` and `Default:` prose is a derivative Doxygen-facing representation, not a new maintained JavaScript documentation syntax.

Valid JSDoc forms outside the supported grammar remain visible unchanged rather than receiving speculative translation.

## Expected Outcomes

The regression suite reports five passing TAP assertions under both `mawk` and GNU awk:

1. ordinary JavaScript passes through unchanged;
2. a canonical required JSDoc parameter is translated;
3. a defaulted optional JSDoc parameter is translated;
4. an optional JSDoc parameter without a default is translated; and
5. unsupported dotted property notation remains unchanged while supported records in the same block still translate.

## Related Decisions

- ADR-000 governs capability scope and epistemic honesty.
- ADR-005 established behavior-focused fixtures.
- ADR-011 governs adoption of the shared JavaScript documentation standard.
- ADR-012 established the JavaScript filter and TAP regression contract.
- ADR-013 established canonical required-parameter translation.
