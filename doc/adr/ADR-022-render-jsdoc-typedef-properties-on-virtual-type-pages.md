# ADR-022: Render JSDoc Typedef Properties on Virtual Type Pages

Date: 2026-09-14

## Status

Accepted

## Context

ADR-021 establishes the Doxygen entity model for named JSDoc virtual typedefs.
Canonical `@typedef {Type} Name` records become line-preserving generated alias
invocations whose Doxygen representation is a named related page.  That page is a
first-class documentation entity and a valid cross-reference target without
pretending that the virtual type is a runtime JavaScript declaration.

The shared JavaScript documentation standard also defines `@property` as the
maintained-source mechanism for documenting meaningful properties of a documented
object type.  A common JSDoc object-shape contract therefore looks like:

```text
@typedef {Object} User
@property {string} name - Display name shown to readers.
```

The property belongs to the virtual typedef contract.  Doxygen has language-level
member commands, but mapping a JSDoc virtual property to a fake JavaScript member,
field, or variable would repeat the semantic problem ADR-021 rejected for virtual
typedefs themselves.  The property is documentation about a virtual object shape;
it is not evidence that a runtime declaration exists.

ADR-018 and ADR-019 establish physical line preservation as part of the Doxygen
input-filter compatibility boundary.  ADR-021 already uses a Doxygen alias to
introduce logical structure inside a virtual type page while keeping one output
record for each input record.  The property representation should preserve the
same boundary.

A property record outside a governed virtual typedef block is ambiguous in this
filter milestone.  JSDoc can use `@property` in contexts beyond the exact virtual
typedef pattern governed here, and translating such a record without an established
parent entity could attach documentation to the wrong Doxygen object.  Visible
pass-through remains the safer false-negative behavior.

## Decision

The filter SHALL support the canonical JSDoc property form:

```text
@property {Type} name - Description.
```

only when all of the following conditions hold:

- the record appears inside a conservatively recognized multi-line JSDoc block;
- an earlier record in the same JSDoc block established a supported virtual typedef
  under ADR-021;
- `name` is a simple JavaScript identifier matching
  `[A-Za-z_$][A-Za-z0-9_$]*`;
- the type expression is non-empty and can be transported safely through the
  governed alias representation; and
- the description is non-empty and can be transported safely through the governed
  alias representation.

A supported record SHALL be translated on the same physical source line to:

```text
@jsproperty{Type||name||Description.}
```

`@jsproperty` is generated Doxygen-facing syntax only.  Maintainers SHALL continue
to write ordinary JSDoc `@property` records and SHALL NOT maintain the generated
alias syntax directly.

The checked-in Doxygen consumer configuration SHALL define an alias equivalent to:

```text
ALIASES += jsproperty{3||}="@par Property: \\2^^Type: \\1.^^\\3"
```

The alias SHALL render the property as structured documentation on the already
established virtual typedef page.  The visible property heading SHALL retain the
exact maintained property name, the maintained type expression SHALL remain
visible textual documentation, and the maintained description SHALL remain visible
prose.

The filter SHALL NOT create a fake JavaScript declaration, Doxygen member, field,
variable, property accessor, class member, or independently named page for the
property.  ADR-021's virtual typedef page remains the reusable, navigable entity.
Properties are child documentation of that entity.

The filter SHALL track whether the current JSDoc block has established a supported
virtual typedef.  That state SHALL reset when a new JSDoc block opens and when the
current block closes.  An unsupported typedef record SHALL NOT establish property
translation state.

A canonical property record that appears before the governed typedef, appears in a
block without a governed typedef, or otherwise falls outside the accepted grammar
SHALL remain visibly unchanged.

The initial alias transport uses `||` as the multi-character field separator.
Property type expressions or descriptions containing that separator remain
unsupported and SHALL pass through unchanged rather than being escaped
speculatively.

This decision does not establish support for:

- dotted or nested property names;
- optional property notation;
- documented property defaults;
- destructured or structural property syntax beyond the canonical form above;
- standalone `@property` contexts not attached to a governed virtual typedef;
- automatic type-expression linking to virtual typedef pages;
- `@callback`; or
- general `@type` handling.

Those behaviors require separate evidence and governance.

## Alternatives Considered

### Leave all `@property` records unchanged

This would preserve maintained source visibly but would leave the first supported
virtual typedef representation unable to carry the structured object-shape
contract that motivates many JSDoc typedefs.  The option was rejected because a
narrow child-property representation can be added without changing the ADR-021
entity model or inventing source semantics.

### Create a Doxygen member or variable for each property

This was rejected because a virtual JSDoc property does not necessarily correspond
to an executable JavaScript field or variable.  Creating member entities would make
the generated documentation claim declarations that may not exist.

### Create a separate related page for every property

This would provide independent link targets but would overstate the identity of a
property and fragment one object-shape contract across many generated entities.
The virtual typedef is the reusable named concept; its properties belong on that
page.

### Translate property records wherever they appear

This was rejected because the filter cannot safely infer the intended Doxygen
parent for every valid JSDoc use of `@property`.  Requiring an already governed
virtual typedef in the same block keeps the recognition boundary inspectable and
prevents accidental attachment to unrelated symbols.

### Add physical lines for property formatting

This was rejected under ADR-018 and ADR-019.  Doxygen alias expansion provides the
logical paragraph structure without changing source/filter line correspondence.

### Parse JavaScript object shapes or infer properties from code

This was rejected because the project is a documentation translator, not a
JavaScript parser or type inference engine.  Maintained JSDoc remains the source of
truth for the documented property contract.

## Consequences

Virtual typedef pages can now preserve canonical property contracts without
fabricating runtime declarations.

The filter gains a small amount of JSDoc-block state: it must remember whether a
supported virtual typedef has been established before deciding whether a property
record is eligible for translation.  The state is documentation-local and does not
perform JavaScript semantic analysis.

The consumer configuration gains one additional alias.  Repositories that consume
virtual typedef properties must load the updated `doxygen-javascript.conf` fragment
or an exactly equivalent alias definition.

Unsupported standalone or complex property forms remain visible.  This may produce
false negatives, but it avoids silently assigning documentation to the wrong entity
or inventing unsupported semantics.

The representation remains one-input-record to one-output-record.  Logical
paragraph structure is introduced only by Doxygen alias expansion.

## Expected Outcomes

For maintained source such as:

```javascript
/**
 * Represents a user record used by formatters.
 *
 * @typedef {Object} User
 * @property {string} name - Display name shown to readers.
 */
```

the filter SHALL emit the ADR-021 typedef alias followed by one `@jsproperty`
record on the corresponding physical source line.  Doxygen SHALL render the
property on the `User` virtual-type page with a visible `Property: name` heading,
`string` as the documented type, and the maintained description.

A canonical `@property` record in a JSDoc block without a supported preceding
virtual typedef SHALL remain unchanged.

The TAP suite SHALL prove both positive translation and negative standalone
pass-through under `mawk` and GNU awk while continuing to enforce physical
line-count equality.  The Doxygen integration suite SHALL prove that the property
heading, type, and description occur in the generated virtual typedef page.

## Compatibility and Migration

Existing governed parameter, return, exception, yield, native-compatible tag, and
virtual typedef behavior is unchanged.

The ADR-021 virtual typedef entity model and deterministic page-label encoding are
unchanged.  This decision only adds child property documentation to that page.

Consumers that do not use translated typedef properties require no behavioral
change.  Consumers that do use them must load a configuration containing both the
ADR-021 `jstypedef` alias and the `jsproperty` alias established here.

This decision does not establish a released consumer artifact or semantic-version
contract.

## Related Decisions

- ADR-000 governs capability claims and executable evidence.
- ADR-005 governs behavior-focused fixtures.
- ADR-012 establishes visible pass-through for unsupported JavaScript documentation
  forms.
- ADR-018 establishes downstream JavaScript/Doxygen integration evidence and
  physical line correspondence as a compatibility concern.
- ADR-019 establishes alias-backed logical documentation without adding physical
  filter lines.
- ADR-021 establishes related pages as the entity model for named virtual JSDoc
  typedefs and explicitly defers property representation to later governance.
