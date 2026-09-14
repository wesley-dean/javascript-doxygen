# JavaScript Documentation Standard Adoption

This repository adopts the JavaScript documentation standard materialized at:

`doc/standards/javascript/documentation-standard.md`

That shared standard defines JSDoc comments as the maintained source of truth for
JavaScript API documentation.  Maintained JavaScript should remain JavaScript-
native; Doxygen compatibility translation belongs at the documentation-generation
boundary rather than in a second maintained documentation dialect.

The shared standard defines the maintained-source contract.  It does not, by
itself, expand the implemented capabilities of `doxygen-javascript.awk`.  Filter
support remains governed by accepted repository-specific ADRs and executable
regression tests.

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
syntax used only at the Doxygen boundary.  Consumers that process translated
yields must load `doxygen-javascript.conf` or an exactly equivalent alias:

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

Doxygen consumers that process translated typedefs must load
`doxygen-javascript.conf` or an exactly equivalent alias.  Generated page labels
are deterministic implementation details used by Doxygen for navigation and
`@ref` targets; they are not maintained-source API and source authors should not be
required to write or know them.

The initial typedef boundary does not establish `@property`, `@callback`, general
`@type`, or automatic linking of arbitrary type expressions to virtual typedef
pages.  Those constructs remain valid maintained JSDoc under the shared standard,
but repository support requires separate governance and executable evidence.

Unsupported parameter and typedef forms remain unchanged.  Dotted property names,
optional dotted properties, rest parameters, destructured parameters, unsupported
typedef names, callbacks, properties, modules, inline tags, general `@type`, and
other JSDoc forms must be claimed only when the filter has corresponding accepted
governance and executable evidence.

## JavaScript/Doxygen integration

ADR-018 establishes executable downstream evidence for governed translation forms.
The integration configuration beneath `test/doxygen/` keeps JavaScript as the
parsed source language by using Doxygen's JavaScript parser and applies
`doxygen-javascript.awk` only as an input filter.

The integration suite generates Doxygen XML and checks semantic structure rather
than relying only on filtered source text.  The contract verifies named parameter
documentation, visible optional/default prose, return documentation in a Doxygen
return section, exception documentation in a Doxygen exception parameter list, a
dedicated alias-backed `Yields` paragraph under ADR-019, native deprecation and
see-also structure under ADR-020, and a named related-page representation for
virtual typedefs under ADR-021.

Use:

```sh
make test-doxygen AWK_BIN=mawk
make test-doxygen AWK_BIN=gawk
```

These tests complement the TAP regression suite; they do not replace it.  TAP
fixtures prove the filter's textual transformation or pass-through boundary and
physical line preservation, while the Doxygen integration surface proves that the
downstream documentation engine interprets selected governed output as intended.

All current governed transformations and native-compatible forms preserve one
physical output record for every input record.  `test/run-tests.sh` checks physical
line-count equality for every fixture.  That line correspondence is part of the
integration boundary because Doxygen associates filtered input with source
locations and source-browser anchors.  ADR-019 and ADR-021 use Doxygen alias
expansion so logical documentation structure does not require the filter to add
physical lines.

A future representation that adds or removes physical lines requires a new
decision and integration evidence; it must not be inherited mechanically from a
sibling language project.

Passing integration tests establish only the explicit forms and Doxygen
configuration exercised by the suite.  They do not establish arbitrary JavaScript
syntax support, complete JSDoc translation, blanket native compatibility, or
semantic type inference.

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
ADR-018 through ADR-021.

Maintained AWK implementation source is governed by:

`doc/standards/awk/documentation-standard.md`

Shared-standard changes belong upstream in `wesley-dean/coding_standards`.
Repository-specific exceptions or translation decisions belong in accepted local
ADRs rather than edits beneath `doc/standards/`.
