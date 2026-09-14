# JavaScript Documentation Standard Adoption

This repository adopts the JavaScript documentation standard materialized at:

`doc/standards/javascript/documentation-standard.md`

That shared standard defines JSDoc comments as the maintained source of truth for
JavaScript API documentation.  Maintained JavaScript should remain JavaScript-
native; Doxygen compatibility translation belongs at the documentation-generation
boundary rather than in a second maintained documentation dialect.

The shared standard defines the maintained-source contract.  It does not, by
itself, expand the implemented capabilities of `doxygen-javascript.awk` or the
governed Doxygen alias configuration.  Support remains governed by accepted
repository-specific ADRs and executable regression tests.  ADR-025 clarifies that
the checked-in `doxygen-javascript.conf` file is repository reference/integration
data; downstream consumers maintain the required aliases in their own Doxyfile
while using one Bashdeps-managed JavaScript filter artifact.  ADR-027 normalizes
that artifact and its normal vendored path to the sibling
`doxygen-<language>.awk` naming convention.

ADR-012 establishes the filter and TAP regression boundary.  ADR-013 adds the
canonical required-parameter form:

```text
@param {Type} name - Description.
```

ADR-014 adds the two canonical optional-parameter forms within the filter's current
simple-name and compact-default grammar:

```text
@param {Type} [name] - Description.
@param {Type} [name=default] - Description.
```

The filter translates these forms to line-preserving Doxygen-facing records with
the simple parameter name immediately after `@param`.  Maintained JSDoc type text
is preserved as visible prose.  Optionality is preserved explicitly, and a
supported documented default is preserved textually without evaluation or
normalization.  Current default-token support requires non-empty text containing
neither whitespace nor `]`.

ADR-016 adds the canonical typed return form:

```text
@returns {Type} Description.
```

Doxygen already recognizes `@returns`, so the filter preserves that command and
moves the maintained JSDoc type expression into visible prose:

```text
@returns Description. Type: Type.
```

The filter preserves the return type text without validation, normalization,
inference, or interpretation.  Singular `@return`, untyped `@returns`, typed
returns without descriptions, and continuation lines remain outside the accepted
return translation boundary.

ADR-017 adds the canonical typed-and-described exception form:

```text
@throws {Type} Description.
```

Doxygen recognizes `@throws` and expects an exception object immediately after the
command.  The filter therefore removes the JSDoc braces and preserves the type in
that native position:

```text
@throws Type Description.
```

The supported exception type is a compact, non-empty token containing no
whitespace.  Description-only `@throws`, type-only `@throws`, throws types with
whitespace, and continuation records remain outside the accepted exception
translation boundary.

ADR-019 adds the canonical typed generator-yield form:

```text
@yields {Type} Description.
```

Doxygen has no native yields command.  The filter therefore emits the generated
Doxygen-facing command on the same physical source line:

```text
@jsyields Type: Type. Description.
```

Maintained JavaScript must continue to use `@yields`; `@jsyields` is derivative
syntax used only at the Doxygen boundary.  A downstream consumer that processes
translated yields must define an equivalent alias in its own Doxyfile:

```text
ALIASES += jsyields="@par Yields^^"
```

The alias introduces a logical line break inside Doxygen so the generated output
contains a dedicated `Yields` paragraph without the filter adding a physical line.
Description-only `@yields`, type-only `@yields`, continuation records, and other
unsupported yields forms remain unchanged.

## Native-Compatible Tags

ADR-020 establishes a second supported path for JSDoc forms that do not require a
Doxygen-facing rewrite.  When canonical JSDoc syntax and Doxygen syntax have
compatible grammar and meaning, the filter should preserve the source record
unchanged and support should be established by downstream evidence rather than by
adding unnecessary translator code.

The first accepted native-compatible forms are:

```text
@deprecated Description.
@see Reference
```

These records remain byte-preserved by the filter.  The integration suite verifies
that Doxygen interprets them as deprecation and see-also documentation.

Native compatibility is not inferred merely from a matching tag name.  Each form
must have focused pass-through coverage, physical line-count preservation, and
Doxygen integration evidence before the repository claims it as supported.  Do
not normalize `@see` to `@sa` or introduce an alias when Doxygen already accepts
the maintained JSDoc command directly.

## Virtual Typedefs

ADR-021 adds the canonical virtual typedef form:

```text
@typedef {Type} Name
```

for simple JavaScript identifiers.  The maintained source remains ordinary JSDoc.
The filter translates the typedef record to a generated `@jstypedef` alias
invocation on the same physical source line.  The alias expands inside Doxygen to
a related page whose visible title is the exact maintained typedef name and whose
body retains both surrounding JSDoc prose and the maintained base type.

The related-page representation is deliberate.  A JSDoc typedef may describe a
reusable documentation type that has no dedicated runtime JavaScript declaration.
The generated representation therefore must not fabricate a JavaScript class,
struct, interface, function, variable, or native typedef declaration merely to
create a Doxygen symbol.

Doxygen consumers that process translated typedefs must define the governed
`jstypedef` alias in their own Doxyfile.  Generated page labels are deterministic
implementation details used by Doxygen for navigation and `@ref` targets; they are
not maintained-source API and source authors should not be required to write or
know them.

ADR-022 adds canonical child properties for governed virtual typedefs:

```text
@property {Type} name - Description.
```

A property is translated only after a supported ADR-021 typedef has already been
established in the same JSDoc block.  The generated representation is:

```text
@jsproperty{Type||name||Description.}
```

on the same physical line.  The consumer Doxyfile alias renders a `Property: name`
paragraph on the existing virtual typedef page and preserves the maintained type
and description as visible documentation.  The property does not become a fake
JavaScript member, field, variable, accessor, or standalone Doxygen page.

A canonical property outside a governed virtual typedef block remains unchanged.
Dotted or optional property names, defaults, nested structural forms, alias-field
content containing the current `||` transport separator, and other complex
property forms remain outside the accepted boundary.

## Virtual Callbacks

ADR-023 adds canonical named callback contracts:

```text
@callback Name
```

for simple JavaScript identifiers.  The maintained source remains ordinary JSDoc.
The filter translates the callback record to a generated `@jscallback` alias
invocation on the same physical source line.  The alias expands inside Doxygen to
a related page whose visible title is the exact maintained callback name.

Callback pages use the same related-page entity model as virtual typedefs because a
named JSDoc callback is a reusable documentation interface that may have no
dedicated runtime function declaration.  The generated representation must not
fabricate a JavaScript function, method, class, interface, variable, or native
Doxygen function symbol merely to make the callback navigable.

Generated callback labels use the deterministic character encoding established for
virtual typedefs with a distinct `jsdocvirtualcallback` prefix.  A callback and a
typedef with the same maintained name therefore remain separate generated entities.
The generated label is derivative representation, not maintained-source API.

Already-governed canonical parameter and return records in the same callback block
retain the ADR-013, ADR-014, and ADR-016 translations.  Doxygen integration tests
prove that those records become parameter and return sections inside the callback
page without requiring a function declaration.  No second callback-specific
parameter or return syntax is maintained while the existing governed
representations remain sufficient.

General JSDoc namepaths such as `Requester~requestCallback` and other scoped
callback names remain outside the accepted boundary.  Those constructs remain
valid maintained JSDoc under the shared standard, but repository support requires
separate governance and executable evidence.

## Symbol Type Annotations

ADR-024 adds canonical JSDoc symbol type annotations:

```text
@type {Type}
```

This capability deliberately does not add an AWK translation.  The maintained
JSDoc record passes through `doxygen-javascript.awk` unchanged and the consumer
Doxyfile supplies the presentation contract:

```text
ALIASES += type="@par Type^^"
```

The simple alias replaces only the command name.  The following maintained type
expression, including its braces, remains source text and is rendered by Doxygen as
the body of a dedicated `Type` paragraph attached to the symbol documented by the
surrounding block.

This is a consumer-alias pass-through capability, distinct from both filter
translation and ADR-020 native-compatible pass-through.  Doxygen does not natively
understand `@type`, and the alias does not make the expression a native Doxygen or
JavaScript semantic type.  The repository preserves the expression text without
validation, normalization, inference, tokenization, or resolution.

The integration fixture proves the maintained `@type {number}` record remains
unchanged through the filter and that Doxygen 1.9.8 attaches the resulting `Type`
paragraph and `{number}` text to the documented JavaScript variable under both
supported AWK implementations.

The consumer alias is not a JSDoc validator.  Repository support claims apply to
the canonical shared-standard form, even though Doxygen may mechanically expand an
alias invocation for noncanonical input as well.

Automatic linking of arbitrary type expressions to ADR-021 virtual typedef pages
or ADR-023 callback pages remains outside the accepted boundary.  Such linking
would require a separate decision about tokenization, name resolution, compound
type expressions, collision behavior, and generated references.

Unsupported parameter, typedef, property, callback, and other complex forms remain
unchanged.  Dotted property names, optional dotted properties, rest parameters,
destructured parameters, unsupported typedef names, standalone properties, complex
callback namepaths, modules, inline tags, automatic type-expression linking, and
other JSDoc forms must be claimed only when the repository has corresponding
accepted governance and executable evidence.

## Consumer Doxyfile Configuration

ADR-025 preserves the sibling-project downstream workflow, with the artifact name
normalized by ADR-027.  A consuming repository uses `bashdeps` to materialize one
released JavaScript filter, conventionally at:

```text
vendor/doxygen-javascript.awk
```

The consumer owns its Doxyfile.  That Doxyfile maps `*.js` input to Doxygen's
JavaScript parser, applies the vendored filter, and defines the aliases required by
current governed representations.  The repository README contains the exact current
consumer setup block.

`doxygen-javascript.conf` is the repository's canonical reference and integration-
test copy of those aliases.  It is not a second Bashdeps dependency and is not part
of the one-file runtime filter contract.

## JavaScript/Doxygen integration

ADR-018 establishes executable downstream evidence for governed translation forms.
The integration configuration beneath `test/doxygen/` keeps JavaScript as the
parsed source language by using Doxygen's JavaScript parser and applies the selected
JavaScript filter only as an input-filter documentation translator.  Repository
integration tests include `doxygen-javascript.conf` so the reference alias block is
exercised end to end.

The integration suite generates Doxygen XML and checks semantic structure rather
than relying only on filtered source text.  The contract verifies named parameter
documentation, visible optional/default prose, return documentation in a Doxygen
return section, exception documentation in a Doxygen exception parameter list, a
dedicated alias-backed `Yields` paragraph under ADR-019, native deprecation and
see-also structure under ADR-020, a named related-page representation for virtual
typedefs under ADR-021, structured property paragraphs on those pages under
ADR-022, named related callback pages with parameter and return sections under
ADR-023, and symbol-local alias-backed `Type` paragraphs under ADR-024.

Use:

```sh
make test-doxygen AWK_BIN=mawk
make test-doxygen AWK_BIN=gawk
```

These tests complement the TAP regression suite; they do not replace it.  TAP
fixtures prove the filter's textual transformation or pass-through boundary and
physical line preservation, while the Doxygen integration surface proves that the
downstream documentation engine interprets selected governed output as intended.
For typedef properties, integration assertions target the generated virtual typedef
page directly so the property heading, type, and description cannot pass merely by
appearing elsewhere in generated source XML.  Callback assertions similarly target
the generated callback page directly and prove its parameter, return, and
cross-reference structure.  ADR-024 type assertions use a dedicated one-symbol
fixture so the documented variable, `Type` paragraph, and retained expression are
unambiguously part of the same generated file documentation surface.

All current governed transformations, native-compatible forms, and consumer-alias
pass-through forms preserve one physical output record for every input record.
`test/run-tests.sh` checks physical line-count equality for every fixture.  That
line correspondence is part of the integration boundary because Doxygen associates
filtered input with source locations and source-browser anchors.  ADR-019 and
ADR-021 through ADR-023 use Doxygen alias expansion so logical documentation
structure does not require the filter to add physical lines.  ADR-024 requires no
filter transformation at all; only Doxygen's consumer-side alias supplies the
logical paragraph structure.

A future representation that adds or removes physical lines requires a new
decision and integration evidence; it must not be inherited mechanically from a
sibling language project.

Passing integration tests establish only the explicit forms and Doxygen
configuration exercised by the suite.  They do not establish arbitrary JavaScript
syntax support, complete JSDoc translation, blanket native compatibility, blanket
consumer-alias support, semantic type inference, or type-expression resolution.

## Repository self-documentation

The repository's own reference documentation is a separate concern from
JavaScript/Doxygen integration.  The maintained implementation source is AWK, so
`doxygen-javascript.awk` is documented with the pinned released `awk-doxygen`
filter.  The TAP harness is Bash and is documented with the pinned released
`bash-doxygen` filter.

ADR-015 governs this self-documentation path.  `make deps-docs` synchronizes the
pinned documentation-only dependencies, `make deps-docs-check` verifies them, and
`make docs` generates project reference documentation beneath `doc/reference/`.
The generated ADR landing page and reference output are not maintained source.

Successful self-documentation does not expand the supported JSDoc surface and does
not substitute for the JavaScript/Doxygen integration evidence governed by
ADR-018 through ADR-024.

Maintained AWK implementation source is governed by:

`doc/standards/awk/documentation-standard.md`

Shared-standard changes belong upstream in `wesley-dean/coding_standards`.
Repository-specific exceptions or translation decisions belong in accepted local
ADRs rather than edits beneath `doc/standards/`.