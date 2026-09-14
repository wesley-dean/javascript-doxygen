# javascript-doxygen

`javascript-doxygen` is a documentation-led Doxygen input-filter project for
JavaScript.  The long-term goal is to let JavaScript remain JavaScript-native,
with JSDoc-style source documentation translated only where Doxygen needs help.

The maintained filter is `doxygen-javascript.awk`.  It currently supports the
canonical simple-parameter forms governed by ADR-013 and ADR-014, canonical typed
`@returns` records governed by ADR-016, canonical typed-and-described `@throws`
records governed by ADR-017, canonical typed `@yields` records governed by ADR-019,
and native-compatible `@deprecated` and `@see` records governed by ADR-020.
ADR-018 exercises governed forms through Doxygen's JavaScript parser.  Unsupported
forms remain unchanged.  The filter does not infer JavaScript semantics or claim
complete JSDoc coverage.

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

`@jsyields` is not maintained JSDoc.  Doxygen consumers that process translated
`@yields` records must load the checked-in `doxygen-javascript.conf` fragment,
which defines:

```text
ALIASES += jsyields="@par Yields^^"
```

The alias introduces the logical paragraph break inside Doxygen.  The filter
itself still emits exactly one physical output line for the input `@yields` line.

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

The maintained JavaScript source remains unchanged.  The filter preserves type and
default text without interpreting either.  Current default-token support requires
non-empty text containing neither whitespace nor `]`.  Typed `@throws` support
requires a compact exception type without whitespace plus a non-empty description.
Unsupported forms such as dotted property notation, singular `@return`, untyped
`@returns`, description-only `@throws`, type-only `@throws`, description-only
`@yields`, and type-only `@yields` continue to pass through unchanged.

All governed transformations preserve one output record for each input record.
The TAP suite checks this invariant for every fixture.  That line correspondence is
part of the Doxygen integration boundary because Doxygen associates filtered input
with source locations and source-browser anchors.

Run the filter with:

```sh
awk -f doxygen-javascript.awk -- path/to/source.js
```

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

The current suite proves twelve behaviors: ordinary JavaScript passes through
unchanged; canonical required parameters translate; optional parameters with and
without compact documented defaults translate; unsupported dotted property
notation remains visible unchanged; canonical typed `@returns` records translate;
singular `@return` remains visible unchanged; canonical typed-and-described
`@throws` records translate; unsupported description-only and type-only `@throws`
forms remain unchanged; canonical typed `@yields` records translate; unsupported
description-only and type-only `@yields` forms remain unchanged; and
native-compatible `@deprecated` and `@see` records pass through unchanged.  Every
fixture also proves that filtering preserves physical line count.

## JavaScript/Doxygen integration

Filter-level golden output and downstream Doxygen interpretation are separate test
surfaces.  ADR-018 establishes `test/doxygen/` as the integration surface and uses
Doxygen's JavaScript parser rather than translating JavaScript into another source
language.  ADR-019 extends that integration surface to the alias-backed `Yields`
representation, and ADR-020 uses the same surface to prove native-compatible tag
semantics.

Run the integration suite with either supported AWK implementation:

```sh
make test-doxygen AWK_BIN=mawk
make test-doxygen AWK_BIN=gawk
```

The integration Doxyfile applies `doxygen-javascript.awk` through
`FILTER_PATTERNS`, loads `doxygen-javascript.conf`, generates XML, and verifies
semantic output structure for governed parameter, return, exception, yield,
deprecation, and see-also forms.  The yields assertions verify a dedicated `Yields`
paragraph plus source-location evidence for the generator fixture.  Native-tag
assertions verify that unchanged `@deprecated` and `@see` records are interpreted
by Doxygen rather than merely surviving the filter.  CI runs this surface
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

The repository was initialized from `python-doxygen`, so some copied Python files,
ADRs, tests, and workflow history remain while the project is migrated.  Their
presence does not mean that `javascript-doxygen` implements Python behavior or that
those interfaces are supported here.

The following capabilities remain deliberately deferred:

- complex JSDoc parameter forms and tags beyond the explicitly accepted contracts;
- generated consumer artifacts and checksums;
- semantic-version release publication; and
- release-artifact canaries.

Those capabilities should be enabled only after their JavaScript-specific
contracts are governed and tested.  ADR-012 records the bootstrap boundary,
ADR-013 governs required parameters, ADR-014 governs optional parameters, ADR-015
governs project self-documentation, ADR-016 governs canonical typed return
translation, ADR-017 governs canonical typed exception translation, ADR-018
governs JavaScript/Doxygen integration testing, ADR-019 governs alias-backed typed
yield translation, and ADR-020 governs evidence-driven native-compatible tag
pass-through.

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

`doc/documentation-standard.md` records this repository's adoption point and the
boundary between the shared maintained-source contract and filter-specific
translation behavior.

Before changing parser boundaries, JSDoc translation behavior, native-compatible
support claims, test contracts, portability, documentation publication, consumer
Doxygen configuration, or release interfaces, review `AGENTS.md`, the applicable
imported standards, all ADRs in `doc/adr/`, and `doc/decisions.md`.

## License

This project is licensed under the Creative Commons License 1.0 Universal License.
See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome.  See [CONTRIBUTING.md](CONTRIBUTING.md) and
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Author

- Wes Dean
