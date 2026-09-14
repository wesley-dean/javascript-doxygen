# javascript-doxygen

`javascript-doxygen` is a documentation-led Doxygen input-filter project for
JavaScript.  The long-term goal is to let JavaScript remain JavaScript-native,
with JSDoc-style source documentation translated only where Doxygen needs help.

The maintained filter is `doxygen-javascript.awk`.  It currently supports the
canonical simple-parameter forms governed by ADR-013 and ADR-014, canonical typed
`@returns` records governed by ADR-016, and canonical typed-and-described `@throws`
records governed by ADR-017.  ADR-018 exercises those governed forms through
Doxygen's JavaScript parser.  Unsupported forms remain unchanged.  The filter does
not infer JavaScript semantics or claim complete JSDoc coverage.

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

The maintained JavaScript source remains unchanged.  The filter preserves type and
default text without interpreting either.  Current default-token support requires
non-empty text containing neither whitespace nor `]`.  Typed `@throws` support
requires a compact exception type without whitespace plus a non-empty description.
Unsupported forms such as dotted property notation, singular `@return`, untyped
`@returns`, description-only `@throws`, and type-only `@throws` continue to pass
through unchanged.

Supported translations preserve one output record for each input record.  That
line correspondence is part of the current Doxygen integration boundary because
Doxygen associates filtered input with source locations and source-browser anchors.

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

The current suite proves nine behaviors: ordinary JavaScript passes through
unchanged; canonical required parameters translate; optional parameters with and
without compact documented defaults translate; unsupported dotted property
notation remains visible unchanged; canonical typed `@returns` records translate;
singular `@return` remains visible unchanged; canonical typed-and-described
`@throws` records translate; and unsupported description-only and type-only
`@throws` forms remain unchanged.  Future documentation translations should grow
the suite one focused behavior at a time.

## JavaScript/Doxygen integration

Filter-level golden output and downstream Doxygen interpretation are separate test
surfaces.  ADR-018 establishes `test/doxygen/` as the integration surface and uses
Doxygen's JavaScript parser rather than translating JavaScript into another source
language.

Run the integration suite with either supported AWK implementation:

```sh
make test-doxygen AWK_BIN=mawk
make test-doxygen AWK_BIN=gawk
```

The integration Doxyfile applies `doxygen-javascript.awk` through
`FILTER_PATTERNS`, generates XML, and verifies semantic output structure for the
currently governed parameter, return, and exception forms.  CI runs this surface
separately from the TAP suite so a textual filter regression can be distinguished
from a downstream Doxygen integration regression.

Generated integration output beneath `test/doxygen/out/` is ephemeral and ignored
by Git.  Passing integration tests demonstrate only the explicitly exercised
forms and configuration; they are not evidence of arbitrary JavaScript or JSDoc
support.

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
presence does not mean that `javascript-doxygen` implements Python behavior or
that those interfaces are supported here.

The following capabilities remain deliberately deferred:

- complex JSDoc parameter forms and tags beyond the accepted parameter, typed
  return, and typed exception contracts;
- generated consumer artifacts and checksums;
- semantic-version release publication; and
- release-artifact canaries.

Those capabilities should be enabled only after their JavaScript-specific
contracts are governed and tested.  ADR-012 records the bootstrap boundary,
ADR-013 governs required parameters, ADR-014 governs optional parameters, ADR-015
governs project self-documentation, ADR-016 governs canonical typed return
translation, ADR-017 governs canonical typed exception translation, and ADR-018
governs JavaScript/Doxygen integration testing.

## Coding standards and governance

This repository adopts the pinned shared standards snapshot under
`doc/standards/`.  `.codingstandardrc` records the concrete upstream release and
verified archive digest.  Applicable imported standards are project requirements;
accepted repository-specific ADRs and explicit local policy may refine them.

Do not edit files beneath `doc/standards/` locally.  Shared-standard changes
belong upstream in `wesley-dean/coding_standards`; repository-specific decisions
belong in this repository's ADRs.

Maintained JavaScript documentation is governed by
`doc/standards/javascript/documentation-standard.md`.  That standard establishes
JSDoc as the maintained source language and defines the canonical authoring forms.
Adopting the standard does not imply that every valid JSDoc construct is already
translated by `doxygen-javascript.awk`; filter capability remains limited to
behavior supported by accepted local ADRs and executable regression tests.

`doc/documentation-standard.md` records this repository's adoption point and the
boundary between the shared maintained-source contract and filter-specific
translation behavior.

Before changing parser boundaries, JSDoc translation behavior, test contracts,
portability, documentation publication, or release interfaces, review
`AGENTS.md`, the applicable imported standards, all ADRs in `doc/adr/`, and
`doc/decisions.md`.

## License

This project is licensed under the Creative Commons License 1.0 Universal
License.  See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome.  See [CONTRIBUTING.md](CONTRIBUTING.md) and
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Author

- Wes Dean
