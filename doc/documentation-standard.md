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
first structured translation for the canonical required-parameter JSDoc form:

```text
@param {Type} name - Description.
```

The filter translates that form to a line-preserving Doxygen-facing record with
the parameter name immediately after `@param` and the maintained JSDoc type
preserved as visible prose.  Unsupported parameter forms remain unchanged.

Optional/default parameters, return values, exceptions, yields, typedefs,
callbacks, properties, modules, inline tags, complex parameter names, and other
JSDoc forms must be claimed only when the filter has corresponding accepted
governance and executable evidence.

Maintained AWK implementation source is governed by:

`doc/standards/awk/documentation-standard.md`

Shared-standard changes belong upstream in `wesley-dean/coding_standards`.
Repository-specific exceptions or translation decisions belong in accepted local
ADRs rather than edits beneath `doc/standards/`.
