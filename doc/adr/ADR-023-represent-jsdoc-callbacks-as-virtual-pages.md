# ADR-023: Represent Named JSDoc Callbacks as Virtual Pages

Date: 2026-09-14

## Status

Accepted

## Context

The shared JavaScript documentation standard defines `@callback` for callback
contracts that deserve a named reusable interface.  JSDoc treats a named callback
similarly to a custom type: after defining it, maintainers may use the callback
name in type expressions such as `@param {Handler} handler - ...`.

A callback documented only through JSDoc may have no dedicated runtime JavaScript
function declaration.  The project therefore needs a Doxygen representation that
preserves the callback as a named, navigable, cross-referenceable documentation
concept without fabricating executable JavaScript.

ADR-021 established Doxygen related pages as the entity model for named virtual
JSDoc typedefs.  That decision rejected fake JavaScript declarations and native
Doxygen structural symbols whose semantics would imply runtime entities that do
not exist.  The same concern applies to JSDoc callbacks.

A callback differs from an object typedef because its contract commonly contains
parameters and a return value.  The repository already has governed,
line-preserving translations for canonical simple `@param` records under ADR-013
and ADR-014 and canonical typed `@returns` records under ADR-016.  Doxygen can
render parameter and return documentation sections within a related page without
creating a function declaration.  The integration suite must prove that behavior
rather than assuming that a same-named documentation command is sufficient.

JSDoc permits callback namepaths such as `Requester~requestCallback`.  The current
virtual-type implementation intentionally starts with simple JavaScript identifiers
so generated page labels can remain deterministic, portable, and easy to audit.
Supporting general JSDoc namepaths requires a separate encoding and scoping
decision.

## Decision

The filter SHALL support the canonical named callback form:

```text
@callback Name
```

when `Name` is a simple JavaScript identifier matching:

```text
[A-Za-z_$][A-Za-z0-9_$]*
```

The filter SHALL translate the callback record on the same physical source line to:

```text
@jscallback{Label||Name}
```

`@jscallback` is generated Doxygen-facing syntax only.  Maintainers SHALL continue
to write ordinary JSDoc `@callback` records and SHALL NOT maintain generated alias
syntax directly.

The generated callback page label SHALL use the same per-character lowercase
encoding established by ADR-021, but SHALL use the distinct prefix:

```text
jsdocvirtualcallback
```

A callback and typedef with the same maintained name therefore SHALL NOT collide in
generated Doxygen documentation.

The checked-in Doxygen consumer configuration SHALL define an alias equivalent to:

```text
ALIASES += jscallback{2||}="@page \\1 \\2^^@par JSDoc callback"
```

The alias SHALL create a Doxygen related page whose visible title is the exact
maintained callback name.  The page SHALL remain a documentation entity; the filter
SHALL NOT synthesize a JavaScript function, method, class, interface, variable, or
native Doxygen function declaration merely to create a callback symbol.

When already-governed canonical parameter and return records occur in the same
callback documentation block, their existing ADR-013, ADR-014, and ADR-016
translations SHALL remain in effect.  Doxygen integration evidence SHALL prove
that those translated records are rendered as parameter and return documentation
inside the callback page without requiring a function declaration.

This decision does not widen the existing parameter or return grammars.  Complex
parameter name forms, unsupported return forms, or other unsupported records remain
subject to their existing visible-pass-through boundaries.

Unsupported callback namepaths, including dotted, tilde-qualified, or otherwise
non-simple JSDoc namepaths, SHALL remain visibly unchanged until separate governance
establishes a portable generated-label and scoping contract for them.

The filter SHALL preserve one physical output record for every input record.
Doxygen aliases may introduce logical formatting, but the input-filter line-count
invariant established by ADR-018 and ADR-019 remains unchanged.

This decision does not establish general `@type` linking, automatic rewriting of
callback names found in arbitrary type expressions, callback namepath scoping, or a
released consumer artifact.

## Alternatives Considered

### Translate callbacks to fake JavaScript functions

Rejected.  A JSDoc callback is a reusable documentation interface and may have no
runtime function declaration.  Fabricating source would violate the project's
JavaScript-native boundary and overstate executable structure.

### Translate callbacks to Doxygen native function symbols

Rejected.  A native function symbol would imply a source-level callable entity.
The callback contract needs a named documentation target without that runtime
claim.

### Render callbacks as anonymous prose

Rejected.  JSDoc callback names are reusable types.  Anonymous prose would preserve
text while losing the identity and cross-reference semantics that motivate
`@callback`.

### Reuse the virtual typedef label namespace

Rejected.  JSDoc can validly use the same identifier text for different kinds of
maintained documentation concepts.  A distinct callback prefix prevents generated
page-label collisions and keeps the entity kind inspectable.

### Immediately support general JSDoc namepaths

Rejected for the initial boundary.  Namepaths introduce scoping and encoding
semantics beyond the simple-identifier contract already proven for virtual typedefs.
Visible pass-through is preferable until those semantics are separately governed.

### Invent callback-specific parameter and return aliases immediately

Rejected unless integration evidence shows the existing governed translations are
insufficient.  Reusing already-proven parameter and return representations keeps the
filter smaller and avoids a second representation for the same maintained syntax.

## Consequences

Named simple callbacks become first-class related-page documentation entities and
valid Doxygen cross-reference targets without becoming fake runtime functions.

The consumer configuration gains one additional alias.  Repositories that consume
translated callbacks must load the updated `doxygen-javascript.conf` fragment or an
exactly equivalent alias definition.

Callback page labels are deterministic and separate from virtual typedef labels.
The label remains generated representation rather than maintained-source API.

Existing governed parameter and return translation code can describe callback
signatures if downstream Doxygen evidence confirms that the resulting sections are
attached to the callback page.  No duplicate callback-specific signature parser is
introduced.

General callback namepaths remain unsupported, producing a deliberate false
negative rather than a speculative generated scope.

## Expected Outcomes

For maintained source such as:

```javascript
/**
 * Handles one normalized value.
 *
 * @callback Handler
 * @param {string} value - Normalized value supplied to the callback.
 * @returns {boolean} True when the value is accepted.
 */
```

the filter SHALL emit a generated `@jscallback` record plus the existing governed
parameter and return translations on their corresponding physical lines.

Doxygen SHALL create a related page titled `Handler`, render a parameter section
for `value`, render a return section containing the maintained return description
and visible type, and resolve `@ref` references to the deterministic callback page
label.

The TAP suite SHALL prove exact callback translation, unsupported namepath
pass-through, and physical line-count preservation under both `mawk` and GNU awk.
The Doxygen integration suite SHALL prove page creation, signature sections, and
cross-reference resolution under both AWK implementations.

## Compatibility and Migration

Existing governed parameter, return, exception, yield, native-compatible tag,
virtual typedef, and typedef-property behavior is unchanged.

Consumers that do not use translated callbacks require no configuration change.
Consumers that do use them must load a configuration containing the new
`jscallback` alias.

This decision does not establish a released consumer artifact or semantic-version
contract.

## Related Decisions

- ADR-000 governs capability claims and executable evidence.
- ADR-005 governs behavior-focused fixtures.
- ADR-012 establishes visible pass-through for unsupported JavaScript documentation
  forms.
- ADR-013 and ADR-014 govern canonical simple parameter translation.
- ADR-016 governs canonical typed return translation.
- ADR-018 establishes downstream JavaScript/Doxygen integration evidence and
  physical line correspondence as a compatibility concern.
- ADR-019 establishes alias-backed logical documentation without adding physical
  filter lines.
- ADR-021 establishes related pages as the entity model for named virtual JSDoc
  types without synthetic runtime declarations.
- ADR-022 establishes structured child documentation on virtual-type pages without
  inventing members.
