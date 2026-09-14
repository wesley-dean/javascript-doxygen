# javascript-doxygen

`javascript-doxygen` is a documentation-led Doxygen input-filter project for
JavaScript.  The long-term goal is to let JavaScript remain JavaScript-native,
with JSDoc-style source documentation translated only where Doxygen needs help.

The maintained filter is `doxygen-javascript.awk`.  Its first implemented JSDoc
translation supports canonical required parameters of the form
`@param {Type} name - Description.` while preserving unsupported forms unchanged.
It does not infer JavaScript semantics or claim a complete Doxygen integration.

## Current capability

For newline-terminated JavaScript input, the filter preserves source records and
translates canonical required JSDoc parameter records inside conservatively
recognized multi-line JSDoc blocks.

For example:

```text
@param {string} name - The name to greet.
```

is translated at the Doxygen boundary to:

```text
@param name The name to greet. Type: string.
```

The maintained JavaScript source remains unchanged.  Unsupported JSDoc forms,
including optional/defaulted parameters, currently pass through unchanged.

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

The current suite proves three behaviors: ordinary JavaScript passes through
unchanged, canonical required JSDoc parameters are translated, and unsupported
optional/defaulted parameters remain visible unchanged.  Future documentation
translations should grow the suite one focused behavior at a time.

## Deferred capabilities

The repository was initialized from `python-doxygen`, so some copied Python files,
ADRs, tests, and workflow history remain while the project is migrated.  Their
presence does not mean that `javascript-doxygen` implements Python behavior or
that those interfaces are supported here.

The following JavaScript-specific capabilities remain deliberately deferred:

- additional JSDoc parameter forms and tags beyond the accepted required-parameter
  contract;
- Doxygen integration tests for JavaScript;
- generated consumer artifacts and checksums;
- documentation canary publication; and
- semantic-version release publication.

Those capabilities should be enabled only after their JavaScript-specific
contracts are governed and tested.  ADR-012 records the bootstrap boundary, and
ADR-013 governs the first required-parameter translation.

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
