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

Unsupported parameter forms remain unchanged.  Dotted property names, optional
dotted properties, rest parameters, destructured parameters, return values,
exceptions, yields, typedefs, callbacks, properties, modules, inline tags, and
other JSDoc forms must be claimed only when the filter has corresponding accepted
governance and executable evidence.

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

Successful self-documentation does not expand the supported JSDoc translation
surface and does not prove that JavaScript source has been exercised through
Doxygen with `doxygen-javascript.awk`.

Maintained AWK implementation source is governed by:

`doc/standards/awk/documentation-standard.md`

Shared-standard changes belong upstream in `wesley-dean/coding_standards`.
Repository-specific exceptions or translation decisions belong in accepted local
ADRs rather than edits beneath `doc/standards/`.
