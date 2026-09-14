# ADR-026: Publish JavaScript release artifacts

Date: 2026-09-14

## Status

Accepted

## Context

ADR-025 establishes the JavaScript-specific build boundary and produces three executable AWK artifacts plus adjacent SHA-256 files:

```text
dist/javascript-doxygen.dev.awk
dist/javascript-doxygen.dev.awk.sha256
dist/javascript-doxygen.awk
dist/javascript-doxygen.awk.sha256
dist/javascript-doxygen.min.awk
dist/javascript-doxygen.min.awk.sha256
```

It deliberately leaves semantic-version release publication for a separate decision.  Issue #19 requests that release mechanism and requires the release workflow to call the governed Make targets rather than recreate build logic in workflow YAML.

The sibling AWK, Bash, and Python Doxygen repositories publish generated filter artifacts as public GitHub release assets so downstream repositories can pin exact versions through `bashdeps`.  Their release workflows provide useful precedent, while the copied Python-specific ADR-007 does not govern JavaScript artifact names or the three-variant build contract established by ADR-025.

The repository already contains semantic-version tags `v0.0.1` and `v0.0.2`.  `v0.0.1` marks the initial Python-tooling import from which this repository was bootstrapped, and `v0.0.2` marks an early shared-standards adoption merge.  Neither tag has a corresponding GitHub Release.  This decision preserves that existing tag lineage rather than resetting version numbers when JavaScript artifact publication begins.

The JavaScript downstream runtime contract remains one file.  A consuming repository uses `bashdeps` to download one released filter, conventionally into:

```text
vendor/javascript-doxygen.awk
```

and configures its own Doxyfile to route `*.js` through that filter and define the required JavaScript aliases.  Publishing development and minified variants must not turn them into additional runtime dependencies.

## Decision Drivers

- Publish exactly the bytes produced by the governed Make build.
- Preserve the one-file downstream runtime dependency model.
- Make the ordinary artifact the obvious, stable Bashdeps consumer choice.
- Publish development and minified variants for inspection and alternative use without changing the canonical consumer contract.
- Publish independent SHA-256 verification metadata for every executable artifact.
- Preserve the repository's existing semantic-version tag lineage.
- Restrict publication to the default `main` branch even when the workflow is manually dispatched.
- Prevent a failed build or validation from leaving a new release tag that appears successful.
- Make retries for an already-tagged commit idempotent rather than minting a second version for the same source revision.
- Validate both maintained source and generated release candidates before publication.
- Verify the exact public release bytes after publication rather than assuming upload success implies a valid release package.
- Keep release automation reproducible, inspectable, and aligned with ADR-025.

## Decision

### Release trigger and versioning

The versioning workflow SHALL run after pushes to `main` and MAY also be invoked manually.  Release-producing jobs SHALL execute only when the workflow ref is `refs/heads/main`; manually dispatching the workflow from another branch SHALL NOT publish a release.

Semantic versions SHALL be calculated from the repository's Conventional Commit history using the existing semantic-version action and `v` tag prefix convention.  The initial version SHALL be `0.0.1` only when no prior semantic-version tag exists.  Because this repository already contains `v0.0.1` and `v0.0.2`, JavaScript release publication SHALL continue from that existing sequence rather than restart it.

Before calculating a new version, the workflow SHALL inspect the exact checked-out `HEAD` for an existing tag matching `v<major>.<minor>.<patch>`.  When such a tag already points at `HEAD`, the workflow SHALL reuse that version for validation, release publication, and canary execution.  This is the retry and recovery path for an already-tagged commit and SHALL NOT calculate another version for the same source revision.

Only an untagged `HEAD` SHALL invoke the semantic-version calculator.  Version calculation SHALL NOT create the tag before validation.  The workflow SHALL first calculate the prospective version, build and validate the release candidates, and only then create the GitHub release and corresponding `v<version>` tag at the exact validated commit.

A validation failure therefore SHALL prevent both release publication and creation of a new release tag by this workflow.  A rerun after the tag already exists SHALL reuse the existing version rather than advancing the release series again.

### Canonical consumer artifact

The canonical normal `bashdeps` consumer artifact SHALL be:

```text
javascript-doxygen.awk
```

This is the ordinary ADR-025 artifact.  It removes only project-governed AWK Doxygen documentation records while preserving ordinary implementation comments, provenance, and executable behavior.

A downstream dependency manifest should pin the exact semantic version, public release-asset URL, and SHA-256 digest for this ordinary artifact.  The development and minified variants are alternate published forms and are not additional runtime requirements.

### Published release assets

Each release SHALL publish exactly these six generated files:

```text
javascript-doxygen.dev.awk
javascript-doxygen.dev.awk.sha256
javascript-doxygen.awk
javascript-doxygen.awk.sha256
javascript-doxygen.min.awk
javascript-doxygen.min.awk.sha256
```

The release workflow SHALL build them by running the root Make lifecycle with the selected release version supplied as provenance:

```text
make all VERSION=<version>
```

Workflow YAML SHALL NOT reproduce development-artifact construction, documentation stripping, minification, or checksum generation.

The release action SHALL fail when an expected asset is missing rather than silently publishing a partial file set.

`doxygen-javascript.conf` SHALL NOT be published as a runtime release asset.  Consumers own the Doxyfile configuration documented by the repository and continue to depend on exactly one AWK filter file at runtime.

### Pre-publication validation

Before release creation, the workflow SHALL:

1. run the repository `make check` target so GNU awk lint passes for the maintained root AWK sources;
2. validate maintained JavaScript filter behavior with both `mawk` and GNU awk;
3. run `make all` once with the selected release version and an explicitly selected supported production AWK implementation;
4. verify all generated checksums;
5. run the complete TAP suite against all three generated artifacts under both supported AWK implementations; and
6. run the JavaScript/Doxygen integration surface against all three generated artifacts under both supported AWK implementations.

The release build SHALL use `mawk` as the explicit production AWK implementation for the minification step.  The already-generated bytes SHALL then be exercised with both `mawk` and GNU awk.  This makes the release byte-production environment explicit while retaining the repository's portable-AWK runtime contract.

The release workflow SHALL use the repository Make targets for these gates rather than duplicating test or integration logic in workflow YAML.

### Release creation

After all pre-publication validation succeeds, the workflow SHALL create a non-draft, non-prerelease GitHub release named for the selected `v<version>` tag and targeted at the exact validated commit.

If that release tag already exists at the exact current commit during a retry, the workflow MAY update or reuse the release for that same tag and SHALL overwrite same-name release assets with the newly validated bytes.  This explicit replacement behavior makes retry recovery deterministic.  The workflow SHALL NOT silently reuse a semantic-version tag that points at a different commit.

GitHub-generated release notes MAY be used.  Release creation SHALL use repository-scoped workflow credentials with only the permissions needed to publish the release and assets.

### Post-publication release canary

A release-artifact canary SHALL run only after the release-creation job succeeds.  It SHALL operate as a dependent job in the same workflow rather than depending on a separate `release.published` event.

The canary SHALL:

1. check out the exact released tag;
2. download all six public release assets through ordinary unauthenticated release URLs;
3. verify all three SHA-256 files against the downloaded AWK artifacts;
4. run the complete TAP suite against each downloaded AWK artifact with both `mawk` and GNU awk; and
5. run the existing Doxygen integration suite against each downloaded AWK artifact with both supported AWK implementations.

The canary SHALL use disposable generated state and SHALL NOT replace stable repository dependencies or update downstream pins.

A canary failure occurs after publication and therefore cannot make an already-published release atomic with validation.  It SHALL nevertheless make packaging or public-download defects immediately visible as a failed release workflow.  The release workflow's pre-publication gates remain the primary prevention boundary.  A retry of that same tagged commit SHALL revalidate and canary the same release version rather than creating version churn.

### Public downstream pinning

Consumers SHALL pin a specific semantic version rather than `main`, `latest`, or another moving reference.  A normal `bashdeps` dependency declaration SHALL use the public release URL for `javascript-doxygen.awk` and the digest from `javascript-doxygen.awk.sha256`.

Public release retrieval SHALL not require GitHub authentication.

Publishing `.dev` and `.min` variants does not alter this normal pinning guidance.  A consumer may deliberately choose another released variant, but that is an explicit consumer choice rather than an additional dependency imposed by this project.

## Alternatives Considered

### Publish only `javascript-doxygen.awk`

Rejected for release packaging because ADR-025 deliberately establishes inspectable development and minified variants and issue #19 explicitly requests publication of all generated AWK artifacts and hashes.  The ordinary artifact remains the canonical normal consumer choice despite the broader release asset set.

### Publish `doxygen-javascript.conf` alongside the filters

Rejected.  ADR-025 establishes a one-file runtime dependency model.  Doxygen aliases belong in the consumer-owned Doxyfile; the checked-in configuration fragment is repository test/reference data.

### Reset JavaScript release numbering to `v0.0.1`

Rejected.  The repository already has `v0.0.1` and `v0.0.2` tags as part of its bootstrap history.  Reusing or rewriting those names would discard visible repository lineage and create unnecessary ambiguity.  JavaScript release publication therefore continues from the existing semantic-version sequence even though the earlier tags were not GitHub Releases.

### Allow manual release publication from arbitrary branches

Rejected.  The public release interface should correspond to reviewed default-branch history.  Manual dispatch remains available for recovery and deliberate reruns, but release-producing jobs are restricted to `main`.

### Create the semantic-version tag before build validation

Rejected.  A failed build could leave a version tag without a valid release, making automation state look more successful than it was.  Version calculation is separated from tag/release creation so validation occurs first.

### Always calculate a new version when the workflow is rerun

Rejected.  The semantic-version action advances from the latest version based on the current commit message even when that same commit is already tagged.  A retry after a canary or publication problem could therefore assign multiple semantic versions to identical source bytes.  Reusing an existing semantic-version tag at `HEAD` makes retry behavior explicit and idempotent.

### Reimplement artifact construction in workflow YAML

Rejected.  Make is the governed build source of truth.  Duplicate construction logic would create a second release-only implementation path that could drift from local and pull-request testing.

### Trust uploaded files without downloading them again

Rejected.  Pre-publication tests prove local release candidates; a post-publication canary proves the exact public bytes and filenames that downstream `bashdeps` users can retrieve.

### Trigger the canary only from a separate `release.published` workflow

Rejected as the primary mechanism because releases created with the repository's default workflow token do not reliably trigger another workflow from that release event.  A dependent canary job in the same workflow provides deterministic post-publication validation without introducing a stronger credential solely to trigger automation.

### Automatically update consumer dependency pins after release

Rejected.  Publishing a dependency and advancing another repository's pin are separate reviewed decisions.

## Consequences

Every successful push to `main` that reaches the versioning workflow can produce a new semantic-version release, consistent with the sibling repositories' established workflow.  Manual dispatch can re-run that lifecycle only from `main`.  Rerunning the workflow for an already-tagged `HEAD` reuses that version rather than producing another version for the same commit.

The first published JavaScript artifact release continues after bootstrap tags `v0.0.1` and `v0.0.2`; assuming no intervening semantic-version tag is introduced, the next release sequence begins at `v0.0.3`.

The release contains three executable representations and three hashes, while normal downstream use remains one vendored AWK file.

Release publication takes longer because it validates maintained source and all generated variants under both portable AWK implementations and Doxygen before publication, then repeats semantic and integration checks against downloaded release bytes afterward.  That additional work is intentional evidence for a dependency artifact consumed by other repositories.

A failure before release creation prevents a new release and tag.  A failure after release creation leaves the release visible but causes the release workflow to fail, making a public-packaging defect explicit for investigation.  Recovery may rerun the same tagged version after correcting external or transient publication conditions; same-name assets are explicitly replaced with freshly validated bytes without incrementing the version merely because the workflow was retried.

Future changes to release asset names, the canonical consumer artifact, semantic-version behavior, dispatch/ref restrictions, retry or tag-reuse behavior, production minifier runtime, checksum publication, public download behavior, or canary scope are compatibility decisions requiring ADR review.

## Expected Outcomes

After this decision is implemented, a successful versioning workflow will publish a release containing all six ADR-025 outputs with release-version provenance.

The ordinary release asset can be pinned by a consumer through `bashdeps` as its single JavaScript Doxygen runtime dependency.

The release workflow will prove the generated candidates before publication and then independently prove the public published bytes after publication.

A retry for a commit that already owns a semantic-version tag will select that existing version, overwrite same-name assets with revalidated bytes, and canary the same release rather than creating a second release version for identical source.

## Compatibility and Migration

No JavaScript Doxygen GitHub Release exists at the time of this decision.  Selecting `javascript-doxygen.awk` as the canonical normal consumer artifact therefore establishes rather than breaks the public release interface.

Bootstrap-era tags `v0.0.1` and `v0.0.2` remain intact and continue to participate in semantic-version calculation.  They are historical repository tags, not prior JavaScript artifact releases.

The existing ADR-025 build names become the release asset names with the `dist/` directory component removed by GitHub asset publication.

The first successful workflow will establish the GitHub Release series on top of the existing semantic-version tag sequence.  Existing source, JSDoc translation, Doxygen alias requirements, and one-file consumer integration remain unchanged.

## Related Decisions

- ADR-000 requires capability and release claims to match executable evidence.
- ADR-007 is copied Python release precedent and does not govern JavaScript artifact names.
- ADR-012 originally deferred copied release behavior.
- ADR-015 governs project self-documentation rather than release publication.
- ADR-018 governs JavaScript/Doxygen integration evidence.
- ADR-025 establishes the JavaScript build artifacts, checksums, Bashdeps build dependency, and one-file consumer model that this decision publishes.
- Issue #19 requests this JavaScript-specific release-publication mechanism.
