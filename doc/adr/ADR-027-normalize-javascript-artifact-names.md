# ADR-027: Normalize JavaScript artifact names to Doxygen-first convention

Date: 2026-09-14

## Status

Accepted

## Context

The maintained JavaScript input filter has always been named:

```text
doxygen-javascript.awk
```

That name follows the same Doxygen-first convention used by the sibling filters:

```text
doxygen-awk.awk
doxygen-bash.awk
doxygen-python.awk
```

ADR-025 later introduced generated JavaScript distribution artifacts using the
opposite word order:

```text
javascript-doxygen.dev.awk
javascript-doxygen.awk
javascript-doxygen.min.awk
```

ADR-026 then made those filenames part of the semantic-version release interface
and identified `javascript-doxygen.awk` as the canonical normal Bashdeps consumer
asset.  Release `v0.0.3` was published with those names.

The inverted generated-artifact convention is internally inconsistent with the
maintained source, with the sibling Doxygen-filter projects, and with the normal
vendor naming convention used by downstream repositories.  The project remains at
an early pre-1.0 release stage, and the release interface has only just been
established.  Correcting the naming now is less costly than carrying a permanent
exception through future documentation, Bashdeps manifests, release automation,
and consumer Doxyfiles.

At the same time, ADR-012 identifies copied Python implementation material as
transitional reference content with no compatibility promise.  The copied root
`doxygen-python.awk` file no longer participates in JavaScript implementation,
testing, documentation generation, build output, or release publication and can be
removed as part of completing the migration away from the bootstrap repository.

## Decision Drivers

- Use one consistent naming convention for maintained source, build artifacts,
  release assets, and vendored consumer paths.
- Match the established AWK, Bash, and Python Doxygen-filter sibling projects.
- Keep the canonical downstream runtime dependency exactly one AWK file.
- Avoid preserving an accidental naming exception merely because one early release
  used it.
- Preserve historical releases rather than rewriting published assets.
- Make the migration explicit so downstream consumers can distinguish old and new
  release filenames unambiguously.
- Remove copied implementation artifacts that no longer serve the JavaScript
  project.

## Decision

### Maintained source

The maintained source filter remains:

```text
doxygen-javascript.awk
```

No source rename is required.

### Generated artifact names

The ADR-025 build lifecycle SHALL generate exactly these executable artifacts:

```text
dist/doxygen-javascript.dev.awk
dist/doxygen-javascript.awk
dist/doxygen-javascript.min.awk
```

with adjacent checksum files:

```text
dist/doxygen-javascript.dev.awk.sha256
dist/doxygen-javascript.awk.sha256
dist/doxygen-javascript.min.awk.sha256
```

The development, ordinary, and minified semantics defined by ADR-025 do not change.
Only the generated filenames change.

### Release asset names

The ADR-026 release workflow SHALL publish those same six basenames as GitHub
release assets:

```text
doxygen-javascript.dev.awk
doxygen-javascript.dev.awk.sha256
doxygen-javascript.awk
doxygen-javascript.awk.sha256
doxygen-javascript.min.awk
doxygen-javascript.min.awk.sha256
```

The canonical normal Bashdeps consumer artifact becomes:

```text
doxygen-javascript.awk
```

The `.dev` and `.min` files remain alternate published representations rather than
additional runtime dependencies.

### Downstream vendor convention

A normal consuming repository SHOULD materialize the canonical released filter as:

```text
vendor/doxygen-javascript.awk
```

and configure its Doxyfile to route `*.js` through that vendored filter.

The one-file runtime dependency model remains unchanged.  The repository reference
file `doxygen-javascript.conf` remains test/reference material and is not a second
Bashdeps dependency or release runtime asset.

### Historical release compatibility

Release `v0.0.3` and any earlier repository history SHALL remain unchanged.
`v0.0.3` legitimately contains the previously governed
`javascript-doxygen*.awk` asset names.

The project SHALL NOT rename, delete, replace, or retroactively republish those
historical release assets merely to make them match the new convention.

Beginning with the first release produced after this ADR, only the normalized
`doxygen-javascript*.awk` names are part of the current release contract.

Consumers pinned to `v0.0.3` continue to use the `javascript-doxygen.awk` URL that
belongs to that release.  Consumers adopting a later release use
`doxygen-javascript.awk`.  Because Bashdeps dependencies are version- and
checksum-pinned, the filename transition is explicit at the dependency-manifest
boundary rather than silently changing bytes behind an existing pin.

### Copied Python filter

The transitional root file:

```text
doxygen-python.awk
```

SHALL be removed from the JavaScript repository.

Historical Python ADRs and references may remain where they explain bootstrap
history or design precedent.  Removing the copied implementation file does not
rewrite that history and does not change the independent `python-doxygen` project.

## Alternatives Considered

### Keep `javascript-doxygen.*` permanently

Rejected.  It would preserve a naming inconsistency between maintained source,
generated artifacts, sibling projects, and downstream vendor paths for no semantic
benefit.

### Rename the maintained source to `javascript-doxygen.awk`

Rejected.  The maintained source already follows the established sibling
Doxygen-first convention.  Renaming the source would spread the inconsistency
instead of correcting it.

### Publish both old and new filenames indefinitely

Rejected.  Dual publication would create two apparent canonical artifact names,
expand the release surface, complicate canary validation, and encourage consumers
to depend on an obsolete alias.  Historical version pinning already preserves
access to the old name where it is needed.

### Rewrite the v0.0.3 release assets

Rejected.  Published release assets are historical evidence.  Mutating them after
publication would weaken reproducibility and make existing checksums and dependency
pins misleading.

### Keep the copied `doxygen-python.awk` as reference material

Rejected.  ADR-012 made no compatibility promise for the copied Python
implementation and explicitly treated it as transitional.  The independent
`python-doxygen` repository is the appropriate maintained reference for that
implementation now that the JavaScript project has its own complete filter,
build, and release lifecycle.

## Consequences

The repository gains one consistent Doxygen-first filename convention across
maintained source, generated artifacts, public release assets, and normal vendored
consumer paths.

The next release after v0.0.3 changes its public asset names.  This is an intentional
pre-1.0 compatibility change and requires downstream Bashdeps manifests to use the
filename appropriate to the pinned release.

No JavaScript/JSDoc translation behavior changes.  Generated artifact contents,
other than provenance text that contains artifact/source names, continue to be
derived by the ADR-025 build process and validated by the same TAP, checksum, AWK,
and Doxygen surfaces.

Release canary logic becomes simpler to compare with sibling repositories because
all filters use the `doxygen-<language>.awk` family of names.

The copied Python root filter disappears from the active JavaScript tree.  Historical
ADRs may still mention it when describing inherited Python behavior and migration
history.

Future changes to the canonical artifact basename or downstream vendor convention
remain public-interface compatibility decisions and require ADR review.

## Expected Outcomes

After this decision is implemented, `make all` will create:

```text
dist/doxygen-javascript.dev.awk
dist/doxygen-javascript.dev.awk.sha256
dist/doxygen-javascript.awk
dist/doxygen-javascript.awk.sha256
dist/doxygen-javascript.min.awk
dist/doxygen-javascript.min.awk.sha256
```

The next successful semantic-version workflow will publish those six basenames and
canary the exact downloaded public bytes.

Normal consumer documentation will point Bashdeps users at
`doxygen-javascript.awk` and show the conventional vendored path
`vendor/doxygen-javascript.awk`.

The root of the JavaScript repository will contain the maintained
`doxygen-javascript.awk` filter and no copied `doxygen-python.awk` implementation.

## Compatibility and Migration

ADR-027 supersedes ADR-025 and ADR-026 only where those decisions specify the
`javascript-doxygen.*` artifact basename or `vendor/javascript-doxygen.awk`
consumer path.  Their build semantics, checksum requirements, release validation,
versioning, retry behavior, and one-file runtime model remain in force.

Release v0.0.3 remains valid under the old naming contract.  No migration is
required for a consumer that remains pinned to v0.0.3.

A consumer upgrading to a release governed by ADR-027 changes its Bashdeps source
URL and destination convention from `javascript-doxygen.awk` to
`doxygen-javascript.awk`, updates the expected SHA-256 digest to the new release
value, and points its Doxyfile filter path at the normalized vendored filename.

## Related Decisions

- ADR-012 establishes `doxygen-javascript.awk` as the maintained JavaScript filter,
  treats copied Python implementation material as transitional, and makes no
  compatibility promise for `doxygen-python.awk` in this repository.
- ADR-025 establishes the three generated artifact forms, their checksums, pinned
  minifier lineage, and source/dist parity requirements.
- ADR-026 establishes semantic-version publication, exact-release-byte canary
  validation, and the one-file Bashdeps consumer contract.
- This ADR supersedes only the artifact and consumer filename portions of ADR-025
  and ADR-026.
