# javascript-doxygen

`javascript-doxygen` is a documentation-led Doxygen input-filter project for
JavaScript.  The long-term goal is to let JavaScript remain JavaScript-native,
with JSDoc-style source documentation translated only where Doxygen needs help.

The project is currently in its bootstrap milestone.  The maintained filter is
`doxygen-javascript.awk`, and its only implemented behavior is source pass-through.
It does not yet translate JSDoc, infer JavaScript semantics, or claim a complete
Doxygen integration.

## Current capability

For newline-terminated JavaScript input, the bootstrap filter writes each source
record back to STDOUT without documentation transformation.

Run it with:

```sh
awk -f doxygen-javascript.awk -- path/to/source.js
```

That deliberately modest behavior gives the project an executable filter boundary
before JSDoc translations are introduced.

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

The bootstrap suite currently contains one intentionally trivial assertion:
ordinary JavaScript passes through the filter unchanged.  Future documentation
translations should grow the suite one focused behavior at a time.

## Deferred capabilities

The repository was initialized from `python-doxygen`, so some copied Python files,
ADRs, tests, and workflow history remain while the project is migrated.  Their
presence does not mean that `javascript-doxygen` implements Python behavior or
that those interfaces are supported here.

The following JavaScript-specific capabilities remain deliberately deferred:

- JSDoc tag translation;
- Doxygen integration tests for JavaScript;
- generated consumer artifacts and checksums;
- documentation canary publication; and
- semantic-version release publication.

Those capabilities should be enabled only after their JavaScript-specific
contracts are governed and tested.  ADR-012 records this bootstrap boundary.

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
