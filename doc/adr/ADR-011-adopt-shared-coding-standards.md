# ADR-011: Adopt Released Shared Coding Standards

Date: 2026-09-14

## Status

Accepted

## Context

This repository was initialized from `python-doxygen` so that the established
Doxygen-filter project structure, test model, documentation practices, and release
infrastructure could provide a starting point for `javascript-doxygen`.  That
initial copy also brought repository-specific governance and duplicated language
documentation guidance that predates this repository's adoption of the shared
standards library.

The canonical reusable coding and documentation standards are maintained in
`wesley-dean/coding_standards`.  That project publishes complete, deterministic
release snapshots together with a SHA-256 checksum and defines a consumer model in
which repositories commit the selected standards beneath `doc/standards/`, record
release provenance in `.codingstandardrc`, and treat applicable standards as
governance.

This repository already uses accepted ADRs as the mechanism for consequential
policy decisions.  Adopting an externally maintained standards library changes the
repository's governance model and therefore requires an explicit local decision
rather than an undocumented copy of upstream files.

## Decision Drivers

- Keep reusable engineering standards in one canonical upstream repository.
- Make the exact governing standards version visible and reproducible.
- Keep standards readable from an ordinary repository checkout, including in
  restricted or offline development environments.
- Preserve repository-specific ADRs as the mechanism for deliberate exceptions or
  refinements.
- Avoid maintaining a second locally edited copy of shared standards.
- Keep standards adoption reviewable as an ordinary repository change.
- Avoid installing permanent standards-fetching or synchronization machinery in
  this repository.

## Decision

The repository SHALL adopt the complete released standards snapshot from
`https://github.com/wesley-dean/coding_standards.git`.

The initial adopted release is:

```text
coding_standards@v1.0.3
```

The verified SHA-256 digest of that release's
`coding_standards.tar.gz` artifact is:

```text
df1f6dc0989a84e60737c6030c48a8fe17dc11976a357fa13efc8abff863f159
```

The selected release resolves to upstream Git commit:

```text
799d8b409e379ce067168cc03d86f327717ba934
```

The complete released standards tree SHALL be materialized beneath:

```text
doc/standards/
```

The project root SHALL contain `.codingstandardrc` recording the canonical source,
concrete release, verified archive digest, and managed destination.

### Authority and applicability

Files beneath `doc/standards/` are governing project requirements rather than
suggestions when they are applicable to maintained content.

Presence does not imply applicability.  General and cross-cutting standards apply
where relevant.  A language-specific standard applies to maintained content in
that language.  Content beneath `doc/standards/examples/` is illustrative and
non-normative unless a governing standard explicitly states otherwise.

Accepted repository-specific ADRs and explicit repository policy may refine or
supersede an imported standard for this repository.  Such exceptions SHALL be
visible governance decisions.  They SHALL NOT be encoded by editing the imported
standard locally or by silently ignoring it.

The current copied Python-specific ADRs remain repository governance until they
are deliberately revised, superseded, or replaced during the separate
JavaScript adaptation work.  Adoption of the shared standards does not itself
reinterpret those decisions as JavaScript decisions and does not authorize a
mechanical Python-to-JavaScript rewrite.

### Managed snapshot

`doc/standards/` SHALL be treated as one externally managed released snapshot.
Local project-specific additions, exceptions, or commentary SHALL NOT be stored
inside that tree.

A future standards upgrade, downgrade, refresh, or repair SHALL replace the
managed tree from a verified concrete release rather than overlaying new files on
top of the existing snapshot.  This prevents standards removed or renamed
upstream from remaining as stale local governance.

Shared standards SHALL NOT be edited locally.  A change to a shared standard
belongs in the canonical `coding_standards` repository and is adopted here later
through a reviewed release update.

### Update mechanism

No permanent standards downloader, updater workflow, Bashdeps standards manifest,
Make synchronization target, Git submodule, or bootstrap script is required by
this decision.

Standards changes SHALL be proposed through ordinary reviewed repository changes
that verify a concrete upstream release, replace the managed snapshot, update
`.codingstandardrc`, and reconcile repository-facing governance.

Existing Bashdeps usage for unrelated documentation-tool dependencies is not
changed by this decision.

### Legacy local standard copies

Files outside `doc/standards/` that were copied from `python-doxygen`, including
local documentation-standard adoption files, are not alternate mutable copies of
the imported standards.  Where those files remain useful as repository-specific
adoption notes or compatibility paths, they SHALL point readers to the applicable
managed standard and local governance.

Future JavaScript adaptation work may remove, rename, or supersede those legacy
paths through separate reviewed changes.  This adoption does not expand scope to
perform that conversion.

## Alternatives Considered

### Continue referencing upstream standards without committing them

This would keep the repository smaller, but normal development and automated
review would depend on network access and a moving external context.  It would
also make the exact standards bytes governing a historical repository state less
obvious.  The released-snapshot model was therefore preferred.

### Copy only standards that appear relevant today

Selective copying would make the consumer responsible for maintaining an
inventory of upstream files and would conflate packaging with applicability.
The complete standards library is small, while applicability can be decided by
repository governance.  The complete release snapshot was therefore preferred.

### Edit imported standards for repository-specific needs

Local edits would make provenance ambiguous and create a fork that could drift
silently from the canonical standards.  Repository-specific exceptions belong in
accepted ADRs or explicit local policy instead.

### Use Bashdeps or a repository-local updater

A downloader or synchronization mechanism could reproduce the files, but it would
add executable maintenance machinery to every consumer for a dependency that
changes infrequently.  The durable state needed here is the committed snapshot,
provenance, and governance.  External maintainer- or agent-mediated adoption
through a reviewed pull request is sufficient.

### Use a Git submodule

A submodule would identify an upstream commit but would not guarantee that the
standards are present in an ordinary checkout.  It would also expose upstream
repository layout rather than the deliberately released standards artifact and
would make governance changes less visible in normal pull-request diffs.

## Consequences

### Positive

- The repository records one concrete, reproducible standards release.
- Applicable shared standards are available from an ordinary checkout.
- Standards changes are visible in pull-request diffs.
- Upstream and repository-specific governance remain clearly separated.
- Accepted local ADRs remain the explicit mechanism for exceptions.
- No permanent synchronization machinery is introduced.
- Future standards refreshes can repair local drift by replacing the complete
  managed tree.

### Negative

- The repository commits derivative copies of standards maintained elsewhere.
- The complete snapshot includes standards for languages that may not apply to
  this project.
- A standards update requires an explicit reviewed repository change.
- During the repository's Python-to-JavaScript transition, some imported language
  standards and copied local governance will coexist even though only the
  standards relevant to maintained content apply.

## Compatibility and Migration

This decision changes repository governance and documentation state only.  It does
not alter the filter's executable behavior, artifact format, public interface, or
release semantics.

The initial adoption materializes `coding_standards@v1.0.3` and records its
verified digest in `.codingstandardrc`.  Existing accepted ADRs retain their
status unless a later decision explicitly supersedes them.

The separate effort to adapt this copied repository from Python to JavaScript will
review those existing decisions individually.  That work must not assume that an
ADR remains valid merely because its Python wording can be mechanically renamed.

## Expected Outcome

A checkout of the repository contains the complete verified `v1.0.3` standards
snapshot beneath `doc/standards/`, provenance in `.codingstandardrc`, and
repository-facing guidance establishing applicable shared standards as mandatory
governance.  Future standards changes are explicit, reproducible, and reviewable,
while repository-specific deviations remain visible local decisions.

## Related Decisions

- ADR-000 governs capability honesty and evidence-oriented claims.
- ADR-006 governs adoption of applicable sibling project infrastructure while
  rejecting mechanical semantic parity.
- The `coding_standards` repository's ADR-003 governs the upstream release and
  consumer-adoption contract represented by this decision.
