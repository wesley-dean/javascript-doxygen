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

ADR-012 therefore continues to govern the current bootstrap implementation:
`doxygen-javascript.awk` performs source pass-through only until a later accepted
JavaScript-specific translation decision supersedes that boundary.

The shared JavaScript standard identifies the canonical required-parameter JSDoc
form as:

```text
@param {Type} name - Description.
```

Support for that form, or for optional/default parameters, return values,
exceptions, yields, typedefs, callbacks, properties, modules, inline tags, or
complex type expressions, must be claimed only when the filter has corresponding
accepted governance and executable evidence.

Maintained AWK implementation source is governed by:

`doc/standards/awk/documentation-standard.md`

Shared-standard changes belong upstream in `wesley-dean/coding_standards`.
Repository-specific exceptions or translation decisions belong in accepted local
ADRs rather than edits beneath `doc/standards/`.
