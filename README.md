# javascript-doxygen

`javascript-doxygen` is a documentation-led Doxygen input-filter project for
JavaScript.  The long-term goal is to let JavaScript remain JavaScript-native,
with JSDoc-style source documentation translated only where Doxygen needs help.

The maintained filter is `doxygen-javascript.awk`.  It currently supports the
canonical simple-parameter forms governed by ADR-013 and ADR-014, canonical typed
`@returns` records governed by ADR-016, canonical typed-and-described `@throws`
records governed by ADR-017, canonical typed `@yields` records governed by ADR-019,
native-compatible `@deprecated` and `@see` records governed by ADR-020, canonical
virtual `@typedef` records governed by ADR-021, canonical properties of those
virtual typedefs governed by ADR-022, canonical named `@callback` contracts
governed by ADR-023, and canonical `@type` annotations governed by ADR-024.
ADR-018 exercises governed forms through Doxygen's JavaScript parser, ADR-025
establishes generated development, ordinary, and minified build artifacts with
adjacent SHA-256 files, ADR-026 publishes those exact artifacts through the
semantic-version release workflow, and ADR-027 normalizes generated, released, and
vendored artifact names to the sibling `doxygen-<language>.awk` convention.
Unsupported forms remain unchanged.  The filter does not infer JavaScript semantics
or claim complete JSDoc coverage.

## Current capability

For newline-terminated JavaScript input, the filter preserves source records and
translates supported JSDoc records inside conservatively recognized multi-line
JSDoc blocks.

A required parameter:

```text
@param {string} name - The name to greet.
```

is translated at the Doxygen boundary to:

```text
@param name The name to greet. Type: string.
```

An optional parameter:

```text
@param {string} [name] - The name to greet.
```

is translated to:

```text
@param name The name to greet. Type: string. Optional.
```

An optional parameter with a compact documented default:

```text
@param {string} [name=World] - The name to greet.
```

is translated to:

```text
@param name The name to greet. Type: string. Optional. Default: World.
```

A typed return value:

```text
@returns {Promise<Configuration>} Validated configuration owned by the caller.
```

is translated to:

```text
@returns Validated configuration owned by the caller. Type: Promise<Configuration>.
```

A typed exception contract:

```text
@throws {TypeError} If the identifier is not a string.
```

is translated to:

```text
@throws TypeError If the identifier is not a string.
```

A typed generator-yield contract:

```text
@yields {Record} Validated records in source order.
```

is translated to the generated Doxygen-facing command:

```text
@jsyields Type: Record. Validated records in source order.
```

`@jsyields` is not maintained JSDoc.  A consumer's Doxyfile must define the
governed `jsyields` alias documented under [Consumer Doxyfile setup](#consumer-doxyfile-setup).
The alias introduces the logical paragraph break inside Doxygen while the filter
continues to emit exactly one physical output line for the input `@yields` line.

Some canonical JSDoc requires no translation.  ADR-020 establishes
native-compatible pass-through for the currently proven forms:

```text
@deprecated Use formatValue instead.
@see formatValue
```

Those records pass through unchanged because Doxygen already accepts the same
commands with compatible semantics.  Native-compatible support remains
form-specific and evidence-driven; a similarly named JSDoc and Doxygen command is
not automatically considered supported.

A named reusable virtual type:

```text
@typedef {Object} User
```

is translated to a generated alias invocation on the same physical line:

```text
@jstypedef{jsdocvirtualtypeuulslelr||User||Object}
```

The maintained source remains ordinary JSDoc.  `@jstypedef` and the encoded page
label are generated representation only.  The consumer Doxyfile alias expands the
record into a Doxygen related page titled `User`, preserves surrounding prose, and
displays the maintained base type.  The page provides a named Doxygen `@ref`
target without fabricating a JavaScript class, struct, interface, typedef
declaration, or other runtime symbol.

A canonical property following that supported typedef in the same JSDoc block:

```text
@property {string} name - Display name shown to readers.
```

is translated on the same physical line to:

```text
@jsproperty{string||name||Display name shown to readers.}
```

The consumer alias renders it as structured child documentation on the `User`
virtual-type page.  The property is not promoted to a fake JavaScript member or a
separate generated entity.  A property outside a governed virtual typedef block
remains visibly unchanged.

A named reusable callback contract:

```text
@callback Handler
@param {string} value - Normalized value supplied to the callback.
@returns {boolean} True when the value is accepted.
```

is represented as a second kind of virtual documentation page.  The callback line
becomes:

```text
@jscallback{jsdocvirtualcallbackuhlalnldlllelr||Handler}
```

while the already-governed parameter and return records retain their existing
translations.  Doxygen renders those sections inside the `Handler` related page,
so the callback remains a named, cross-referenceable interface without fabricating
a JavaScript function declaration.  Callback labels use a distinct generated
namespace from typedef labels so equal maintained names cannot collide.

A canonical symbol type annotation:

```text
@type {number}
```

passes through `doxygen-javascript.awk` unchanged.  ADR-024 governs this as a
consumer-configuration capability rather than an AWK translation.  The consumer's
Doxyfile defines:

```text
ALIASES += type="@par Type^^"
```

Doxygen then renders the maintained expression, including its braces, as a
symbol-local `Type` paragraph.  The alias does not parse or validate the type and
does not make the expression a native Doxygen or JavaScript semantic type.

The maintained JavaScript source remains unchanged.  The filter preserves type and
default text without interpreting either.  Current default-token support requires
non-empty text containing neither whitespace nor `]`.  Typed `@throws` support
requires a compact exception type without whitespace plus a non-empty description.
Virtual typedef, supported typedef-property, and supported callback names currently
require simple JavaScript identifiers.  Unsupported forms such as dotted property
notation, singular `@return`, untyped `@returns`, description-only `@throws`,
type-only `@throws`, description-only `@yields`, type-only `@yields`, dotted
typedef names, untyped typedefs, standalone properties, complex property forms,
and callback namepaths such as `Requester~requestCallback` continue to pass through
unchanged.

All governed transformations preserve one output record for each input record.
The TAP suite checks this invariant for every fixture.  Supported pass-through
forms, including ADR-024 `@type`, preserve the original record completely.  That
line correspondence is part of the Doxygen integration boundary because Doxygen
associates filtered input with source locations and source-browser anchors.

Run the maintained filter directly with:

```sh
awk -f doxygen-javascript.awk -- path/to/source.js
```

## Consumer Doxyfile setup

The downstream runtime model is deliberately the same as the sibling AWK, Bash,
and Python Doxygen filters.  A consuming repository uses `bashdeps` to pin one
released JavaScript filter and materialize it beneath its own `vendor/` directory,
conventionally as:

```text
vendor/doxygen-javascript.awk
```

The consuming repository owns its Doxyfile.  Configure JavaScript parsing and the
vendored filter there, together with the aliases required by the current governed
representations:

```text
EXTENSION_MAPPING = js=JavaScript
FILTER_PATTERNS   = *.js="awk -f vendor/doxygen-javascript.awk --"

ALIASES += jsyields="@par Yields^^"
ALIASES += jstypedef{3||}="@page \1 \2^^@par JSDoc virtual type^^Base type: \3."
ALIASES += jsproperty{3||}="@par Property: \2^^Type: \1.^^\3"
ALIASES += jscallback{2||}="@page \1 \2^^@par JSDoc callback"
ALIASES += type="@par Type^^"
```

The exact invocation may select a different AWK executable where required by the
consumer, but the vendored JavaScript filter remains the one runtime dependency.
The checked-in `doxygen-javascript.conf` file is the repository's canonical
integration-test/reference copy of the alias definitions.  Consumers do not fetch
that file through `bashdeps`; they maintain the required alias configuration in
their own Doxyfile.

## Build artifacts

ADR-025 establishes a local deterministic build surface, with artifact naming
normalized by ADR-027.  `awk-minifier` is pinned in `dependencies.txt` and
synchronized through `bashdeps` as `vendor/awk-minifier.awk`.

From an unprepared checkout, run:

```sh
make all
```

`make all` prepares the pinned build dependency and creates:

```text
dist/doxygen-javascript.dev.awk
dist/doxygen-javascript.dev.awk.sha256
dist/doxygen-javascript.awk
dist/doxygen-javascript.awk.sha256
dist/doxygen-javascript.min.awk
dist/doxygen-javascript.min.awk.sha256
```

The development artifact contains the complete documented maintained filter plus
comment-only build provenance.  The ordinary artifact removes only the project's
AWK Doxygen documentation records while preserving executable behavior and
ordinary implementation comments.  The minified artifact applies the pinned
released AWK Minifier to the ordinary artifact body while regenerating provenance
outside the minifier input.

For already prepared dependency state, `make build` is network-free.  `make
deps-check` verifies the pinned build dependency without repair.  The generated
artifacts and hashes are ignored build state and are not committed.

Validate generated artifact shape, checksums, and TAP parity with:

```sh
make test-dist AWK_BIN=mawk
make test-dist AWK_BIN=gawk
```

When Doxygen is available, exercise every generated artifact through the downstream
integration suite with:

```sh
make test-dist-doxygen AWK_BIN=mawk
make test-dist-doxygen AWK_BIN=gawk
```

## Releases

ADR-026 publishes the generated build outputs through the semantic-version
workflow, with current asset naming normalized by ADR-027.  The ordinary release
asset:

```text
doxygen-javascript.awk
```

is the canonical normal `bashdeps` consumer artifact.  Releases also publish the
`.dev` and `.min` variants for inspection or deliberate alternate use, together
with one `.sha256` file for each AWK artifact.  Publishing those variants does not
change the normal one-file runtime dependency model.

Release v0.0.3 remains historically valid with the earlier
`javascript-doxygen*.awk` asset names.  Releases governed by ADR-027 use only the
normalized `doxygen-javascript*.awk` names; published historical assets are not
renamed or replaced.

The release workflow calculates the prospective semantic version without creating
a tag, validates maintained source plus all three generated filters under both
`mawk` and GNU awk and through Doxygen, then creates the `v<version>` release at the
exact validated commit.  All six generated files are uploaded as release assets.
A dependent post-publication canary downloads the public release assets, verifies
all three hashes, and repeats TAP and Doxygen integration against every downloaded
filter under both supported AWK implementations.

A normal consuming repository should pin a specific current release of
`doxygen-javascript.awk` in its `bashdeps` manifest using the public release-asset
URL and the digest from `doxygen-javascript.awk.sha256`.  Consumers remaining on
v0.0.3 continue to use that release's historical `javascript-doxygen.awk` filename.
Consumers should not pin `main`, `latest`, or another moving reference.

## Regression tests

Behavior-focused source fixtures live under:

```text
test/fixtures/
```

Golden filtered output lives under:

```text
test/expected/
```

The regression harness is:

```text
test/run-tests.sh
```

It emits TAP version 13 output.  Run the current suite with either supported AWK
implementation:

```sh
make test AWK_BIN=mawk
make test AWK_BIN=gawk
```

The current suite proves nineteen behaviors: ordinary JavaScript passes through
unchanged; canonical required parameters translate; optional parameters with and
without compact documented defaults translate; unsupported dotted property
notation remains visible unchanged; canonical typed `@returns` records translate;
singular `@return` remains visible unchanged; canonical typed-and-described
`@throws` records translate; unsupported description-only and type-only `@throws`
forms remain unchanged; canonical typed `@yields` records translate; unsupported
description-only and type-only `@yields` forms remain unchanged; native-compatible
`@deprecated` and `@see` records pass through unchanged; canonical virtual
`@typedef` records translate to related-page aliases; unsupported typedef forms
remain unchanged; canonical properties following a governed virtual typedef
translate to page paragraphs; standalone properties remain unchanged; canonical
simple callbacks translate to virtual callback pages; unsupported callback
namepaths remain unchanged; and canonical `@type` annotations pass through
unchanged.  Every fixture also proves that filtering preserves physical line
count.

## JavaScript/Doxygen integration

Filter-level golden output and downstream Doxygen interpretation are separate test
surfaces.  ADR-018 establishes `test/doxygen/` as the integration surface and uses
Doxygen's JavaScript parser rather than translating JavaScript into another source
language.  ADR-019 extends that integration surface to the alias-backed `Yields`
representation, ADR-020 uses the same surface to prove native-compatible tag
semantics, ADR-021 uses it to prove named virtual typedef pages and cross-reference
resolution, ADR-022 proves that governed properties render on the corresponding
virtual-type page, ADR-023 proves named callback pages with parameter and return
sections, and ADR-024 proves consumer-alias rendering for byte-preserved `@type`
annotations.  ADR-025 additionally requires the generated artifacts to preserve
that tested behavior, and ADR-026 reuses the same evidence against exact published
release bytes.

Run the integration suite with either supported AWK implementation:

```sh
make test-doxygen AWK_BIN=mawk
make test-doxygen AWK_BIN=gawk
```

The repository integration Doxyfile applies the selected JavaScript filter through
`FILTER_PATTERNS`, includes the repository-only `doxygen-javascript.conf` reference
fragment, generates XML, and verifies semantic output structure for governed
parameter, return, exception, yield, deprecation, see-also, virtual typedef,
typedef-property, callback, and type-annotation forms.  The yields assertions verify
a dedicated `Yields` paragraph plus source-location evidence for the generator
fixture.  Native-tag assertions verify that unchanged `@deprecated` and `@see`
records are interpreted by Doxygen rather than merely surviving the filter.  The
typedef assertions verify a named related page, retained source prose and base
type, and a resolved Doxygen `@ref` to the generated virtual type.  The property
assertions verify the `Property: name` heading, documented type, and maintained
description inside that virtual typedef page.  Callback assertions verify the
named related page, parameter and return sections inside that page, and a resolved
Doxygen `@ref` to the generated callback label.  Type-annotation assertions verify
the documented JavaScript symbol, a `Type` paragraph attached to its documentation,
and retention of the maintained JSDoc type expression.  CI runs this surface
separately from the TAP suite so a textual filter regression can be distinguished
from a downstream Doxygen integration regression.

Generated integration output beneath `test/doxygen/out/` is ephemeral and ignored
by Git.  Passing integration tests demonstrate only the explicitly exercised forms
and configuration; they are not evidence of arbitrary JavaScript or JSDoc support.

## Project reference documentation

Project self-documentation is separate from JavaScript/Doxygen integration.  The
maintained implementation is AWK, so `doxygen-javascript.awk` is documented with
the pinned released `awk-doxygen` filter.  The Bash TAP harness is documented with
the pinned released `bash-doxygen` filter.

Prepare and generate the project reference documentation with:

```sh
make deps-docs
make deps-docs-check
make docs AWK_BIN=mawk
```

The generated ADR landing page lives at `doc/adr/README.md`, and Doxygen HTML is
written beneath `doc/reference/`.  Both outputs, together with the synchronized
`vendor/` dependencies, are generated state and are ignored by Git.

A documentation canary exercises this path in pull requests.  Pushes to `main`
generate the same reference documentation and publish `doc/reference/` to GitHub
Pages.  ADR-015 governs this self-documentation boundary.

## Deferred capabilities

The repository was initialized from `python-doxygen`, so some copied Python ADRs,
tests, and historical references remain while the project is migrated.  Their
presence does not mean that `javascript-doxygen` implements Python behavior or that
those interfaces are supported here.  ADR-027 removes the copied root
`doxygen-python.awk` implementation now that the JavaScript filter has its own
complete build and release lifecycle.

The following capabilities remain deliberately deferred:

- complex JSDoc parameter and property forms beyond the explicitly accepted
  contracts;
- scoped or otherwise complex callback namepaths; and
- automatic linking of arbitrary type expressions to virtual typedef or callback
  pages.

Those capabilities should be enabled only after their JavaScript-specific
contracts are governed and tested.  ADR-012 records the bootstrap boundary,
ADR-013 governs required parameters, ADR-014 governs optional parameters, ADR-015
governs project self-documentation, ADR-016 governs canonical typed return
translation, ADR-017 governs canonical typed exception translation, ADR-018
governs JavaScript/Doxygen integration testing, ADR-019 governs alias-backed typed
yield translation, ADR-020 governs evidence-driven native-compatible tag
pass-through, ADR-021 governs related-page representation for virtual typedefs,
ADR-022 governs canonical child properties of those virtual typedefs, ADR-023
governs named virtual callback pages, ADR-024 governs byte-preserved canonical
`@type` annotations rendered through consumer configuration, ADR-025 governs the
local generated distribution build surface, ADR-026 governs semantic-version
release publication and the exact-public-bytes canary, and ADR-027 governs the
normalized Doxygen-first artifact and consumer filename convention.

## Coding standards and governance

This repository adopts the pinned shared standards snapshot under
`doc/standards/`.  `.codingstandardrc` records the concrete upstream release and
verified archive digest.  Applicable imported standards are project requirements;
accepted repository-specific ADRs and explicit local policy may refine them.

Do not edit files beneath `doc/standards/` locally.  Shared-standard changes belong
upstream in `wesley-dean/coding_standards`; repository-specific decisions belong in
this repository's ADRs.

Maintained JavaScript documentation is governed by
`doc/standards/javascript/documentation-standard.md`.  That standard establishes
JSDoc as the maintained source language and defines the canonical authoring forms.
Adopting the standard does not imply that every valid JSDoc construct is already
translated or otherwise supported by `doxygen-javascript.awk`; filter capability
remains limited to behavior supported by accepted local ADRs and executable
regression tests.

Before changing parser boundaries, JSDoc translation behavior, native-compatible
or consumer-alias support claims, test contracts, portability, documentation
publication, consumer Doxygen configuration, virtual-type representation, build
artifacts, or release interfaces, review `AGENTS.md`, the applicable imported
standards, all ADRs in `doc/adr/`, and `doc/decisions.md`.

## License

This project is licensed under the Creative Commons License 1.0 Universal License.
See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome.  See [CONTRIBUTING.md](CONTRIBUTING.md) and
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Author

- Wes Dean