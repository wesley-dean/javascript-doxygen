# ADR-015: Restore Project Self-Documentation and Pages Publication

Date: 2026-09-14

## Status

Accepted

## Context

ADR-012 deferred inherited documentation generation while `javascript-doxygen`
was being separated from copied Python-specific behavior.  That correctly avoided
claiming JavaScript/Doxygen integration before it existed, but it also deferred an
independent capability: documenting this repository's own implementation.

The maintained implementation is AWK and the TAP runner is Bash.  Those sources
can be documented now with the released `awk-doxygen` and `bash-doxygen` filters
already pinned in `dependencies-docs.txt`.  `adrctl` can generate the ephemeral ADR
landing page used by the reference site.

The failing Pages workflow exposed this distinction.  Missing `deps-docs`,
`deps-docs-check`, and `docs` targets mean self-documentation infrastructure is
incomplete; they do not mean JavaScript/Doxygen integration is required first.

## Decision

`javascript-doxygen` SHALL support project self-documentation independently of its
JavaScript translation capabilities.

The Makefile SHALL provide real `deps-docs`, `deps-docs-check`, `adr-index`,
`docs`, `docs-canary`, and `docs-clean` targets.  Documentation dependencies SHALL
remain version-pinned and digest-verified through `dependencies-docs.txt` and
bashdeps.

The Doxyfile SHALL describe `javascript-doxygen`.  `doxygen-javascript.awk` SHALL
be documented with `awk-doxygen`; `test/run-tests.sh` SHALL be documented with
`bash-doxygen`; project Markdown governance and ADRs MAY be included directly.

Generated dependency and documentation state, including `vendor/`,
`doc/reference/`, and `doc/adr/README.md`, SHALL remain untracked.

GitHub Pages SHALL generate and publish project reference documentation after
pushes to `main`.  Pull requests SHALL exercise the same self-documentation path
through a documentation canary so publication failures are found before merge.

This ADR supersedes ADR-012 only where ADR-012 deferred project
self-documentation generation and publication.  ADR-012 continues to defer:

- exercising JavaScript source through Doxygen with `doxygen-javascript.awk`;
- JavaScript/Doxygen integration assertions;
- generated consumer artifacts and checksums;
- semantic-version release publication; and
- release-artifact canaries.

Generated project reference documentation MUST NOT be presented as evidence that
JavaScript/Doxygen integration is complete.

## Alternatives Considered

Keeping all documentation deferred was rejected because it unnecessarily couples
AWK/Bash self-documentation to JavaScript translation support.

Using `javascript-doxygen` to document its own AWK implementation was rejected
because `awk-doxygen` is the language-appropriate filter.

No-op documentation targets were rejected because they would provide false green
checks without generating documentation.

Restoring the copied Python Doxyfile unchanged was rejected because it names and
references the wrong project and source paths.

## Consequences

Self-documentation and JavaScript/Doxygen integration become two explicit,
separate capabilities.  The former can be published continuously while the latter
grows incrementally under its own ADRs and tests.

Documentation failures become visible in pull requests rather than only after a
merge triggers Pages deployment.

## Expected Outcomes

A documentation-capable environment can run:

```sh
make deps-docs
make deps-docs-check
make docs AWK_BIN=mawk
```

and produce ignored `doc/adr/README.md` and `doc/reference/index.html` output.

## Related Decisions

- ADR-000 governs capability scope and epistemic honesty.
- ADR-006 governs selective reuse of sibling infrastructure.
- ADR-011 governs shared coding standards adoption.
- ADR-012 remains authoritative for deferred JavaScript/Doxygen integration and
  release capabilities except for the self-documentation deferral superseded here.
- ADR-013 and ADR-014 govern supported JSDoc parameter translations.
