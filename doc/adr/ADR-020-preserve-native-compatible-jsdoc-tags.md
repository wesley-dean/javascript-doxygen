# ADR-020: Preserve Native-Compatible JSDoc Tags

Date: 2026-09-14

## Status

Accepted

## Context

`javascript-doxygen` exists to translate JSDoc only where Doxygen needs help.  The
project has already established explicit translations for syntax whose maintained
JSDoc representation differs materially from Doxygen's command grammar, including
parameters, returns, exceptions, and yields.

Some baseline JSDoc tags are already valid Doxygen commands with compatible
meaning.  Rewriting those records would add parser logic and generated syntax
without improving the downstream representation.  It would also create additional
places where the filter could alter otherwise valid maintained documentation.

The shared JavaScript documentation standard includes `@deprecated` and `@see` in
its baseline vocabulary.  Doxygen natively recognizes both commands.  The project
now has a downstream integration surface under ADR-018, so native compatibility can
be demonstrated rather than assumed.

A general rule is needed for tags that require no translation while preserving the
project's requirement that capability claims follow executable evidence.

## Decision

When a canonical maintained JSDoc tag is syntactically and semantically compatible
with Doxygen, `doxygen-javascript.awk` SHOULD preserve that record unchanged rather
than translating it to alternate Doxygen syntax.

Native-compatible support SHALL remain evidence-driven.  A JSDoc tag MUST NOT be
claimed as supported merely because Doxygen exposes a command with the same or a
similar name.  The accepted form must have:

- a focused filter-level fixture proving unchanged pass-through;
- physical line-count preservation under the TAP harness; and
- downstream Doxygen integration evidence showing the intended semantic structure
  or rendering.

The first accepted native-compatible forms are:

```text
@deprecated Description.
@see Reference
```

For these forms, the filter SHALL emit the source record unchanged.

The Doxygen integration suite SHALL verify that `@deprecated` is interpreted as
deprecation documentation and that `@see` is interpreted as a see-also section.
The filter SHALL NOT normalize `@see` to `@sa`, wrap either tag in a custom alias,
or otherwise rewrite their maintained syntax merely for generated-output
uniformity.

This decision establishes a method for accepting future native-compatible tags.  It
does not automatically accept every JSDoc tag whose spelling resembles a Doxygen
command.  Each additional tag or materially different form requires executable
evidence and documentation of its support boundary.  A new ADR is required only
when the added form introduces a consequential semantic, compatibility, parser, or
consumer-configuration decision not already governed here.

## Alternatives Considered

### Rewrite all recognized JSDoc tags

This was rejected because translation has cost and risk.  When maintained JSDoc is
already a faithful Doxygen command, rewriting it provides no useful compatibility
benefit and expands the filter unnecessarily.

### Normalize `@see` to Doxygen's `@sa` alias

This was rejected because Doxygen already accepts `@see`.  Replacing one native
command with another would change source representation without changing meaning.

### Treat unchanged tags as unsupported

This was rejected because pass-through can be a fully supported behavior when the
downstream engine interprets the maintained syntax correctly.  Support is defined
by the complete source-to-filter-to-Doxygen behavior, not by whether the AWK filter
changed bytes.

### Claim all same-named JSDoc and Doxygen tags as supported

This was rejected because identical command names do not prove identical grammar
or semantics.  The project's epistemic-honesty rule requires executable evidence
for each claimed support boundary.

### Add custom aliases for native-compatible tags

This was rejected because aliases introduce consumer configuration dependencies.
ADR-019 accepts such a dependency for yields only because Doxygen lacks a native
yields command.  No comparable need exists for `@deprecated` or `@see`.

## Consequences

The filter remains smaller and easier to inspect by translating only documentation
forms that require translation.

Maintained JavaScript can use ordinary JSDoc `@deprecated` and `@see` records
without a generated intermediary command or additional consumer configuration.

The distinction between pass-through and unsupported syntax becomes explicit:
unchanged text may be a supported behavior when both filter-level and downstream
integration evidence establish the intended semantics.

Future native-compatible tags can be added incrementally without adding parser
functions when existing governance is sufficient.  Their support still requires
focused fixtures and integration evidence.

Physical line correspondence remains unchanged because native-compatible records
are preserved exactly.

## Expected Outcomes

A source record such as:

```text
@deprecated Use formatValue instead.
```

and a source record such as:

```text
@see formatValue
```

pass through the filter unchanged.  Doxygen interprets the first as deprecation
documentation and the second as see-also documentation.

The TAP suite protects the exact pass-through behavior and line count.  The Doxygen
integration suite protects downstream semantics.

## Compatibility and Migration

This decision does not change existing translated forms or consumer configuration.
It documents and tests behavior that is already naturally produced by the filter's
conservative pass-through model.

No migration is required for maintained source that already uses canonical
`@deprecated` or `@see` forms.

## Related Decisions

- ADR-000 governs capability claims and executable evidence.
- ADR-012 establishes conservative pass-through as the filter baseline.
- ADR-018 establishes downstream JavaScript/Doxygen integration testing.
- ADR-019 protects physical line correspondence and demonstrates when a custom
  consumer alias is justified by missing native Doxygen semantics.
