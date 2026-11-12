# ADR-028: Consolidate GitHub Actions Dependabot Version Updates

Date: 2026-11-12

## Status

Accepted

## Decision

Keep the repository's weekly GitHub Actions Dependabot version-update
schedule and seven-day cooldown. Replace the `minor-and-patch` group with
one broadly matching `actions-version-updates` group for eligible routine
major, minor, and patch version updates. Explicitly set
`applies-to: version-updates` and `patterns: ["*"]`; do not set
`update-types` in this group.

Security updates remain independent of the schedule and routine group.
Retain the current `dependabot/fetch-metadata` auto-merge condition,
which excludes updates whose highest category is
`version-update:semver-major`. A grouped PR containing a major update
must receive deliberate manual review, with relevant compatibility,
supply-chain, and CI evidence, before merging.

## Context

The repository's existing configuration schedules updates weekly with a
seven-day cooldown, while grouping only minor and patch GitHub Actions
versions. Major updates form separate routine PRs. The imported
`coding_standards@v3.2.0` release introduces a balanced maintenance
recommendation that reduces eligible routine PR fragmentation.

javascript-doxygen is an AWK-based JSDoc translator for Doxygen's JavaScript
parsing boundary. Its behavior, TAP fixtures, JavaScript/Doxygen integration,
source/documentation generation, generated artifact filenames, and release
publication are governed by Accepted ADRs through ADR-027. GitHub Actions
dependencies touch test, documentation canary, and artifact publication
workflows. Grouping changes must not silently modify those contracts.

## Assumptions and Constraints

- Only `github-actions` is currently configured as a Dependabot ecosystem.
- The weekly schedule, seven-day cooldown, and commit conventions remain.
- The current non-major-only auto-merge workflow condition is preserved.
- Grouped updates can include breaking major changes; reviewers must inspect
  migration requirements and affected trust boundaries for every dependency.
- Effective GitHub rulesets, required status checks, CODEOWNERS enforcement,
  and Dependabot security-update settings require separate verification and
  are not proven by local YAML.
- This decision does not permit wider workflow permissions, changed check
  identities, generated artifact changes, or altered release authority.

## Alternatives Considered

1. **Keep minor/patch-only grouping.** Rejected as the default because it
   sustains separate major-update PR overhead without independently
   strengthening their review.
2. **Group major, minor, and patch routine version updates.** Chosen while
   preserving manual review and keeping major-containing PRs out of the
   existing automated non-major merge path.
3. **Change to monthly version updates or lengthen cooldown.** Not chosen
   because slower visibility was not established as suitable for the current
   maintenance needs.
4. **Auto-merge major-containing groups.** Rejected due to compatibility,
   action permissions, release integrity, and artifact provenance risks.
5. **Close existing Dependabot PRs immediately.** Rejected because changing
   grouping does not establish that existing updates have been replaced
   or fully tested.

## Consequences and Migration

Routine GitHub Actions version updates may consolidate into fewer proposals,
but Dependabot resolution constraints and incompatible grouped upgrades can
still produce separate PRs. A failure may be harder to isolate; a narrow
reviewed grouping exception may be warranted when the evidence supports it.

Review every dependency in a group, especially privileged Actions and any
changes that affect testing, generated documentation, artifacts, CI tokens,
or release publication. The highest-risk change sets the review standard.
Security fixes must not be routed into or delayed by routine grouping.

Leave existing Dependabot PR #32 open until an observed replacement is proven
to contain equivalent updates and passes appropriate verification. Retain the
existing non-major-only auto-merge boundary, required checks, permissions, and
normal human review. No change to runtime, JavaScript/JSDoc semantics, AWK
portability, release contracts, or exported artifacts is authorized here.

## Expected Outcomes and Verification

Observe subsequent scheduled Dependabot updates, confirm major-containing
groups do not enter the non-major auto-merge path, and compare actual
dependency coverage, PR count, CI behavior, and review effort. Do not promise
a particular PR-count reduction. Verify effective GitHub security-update
settings and review protections separately rather than assuming compliance.

## Related Decisions

ADR-011 establishes adoption of verified external standards; ADR-012 through
ADR-027 govern JavaScript translation, integration evidence, build artifacts,
and release behavior. This decision supplements those boundaries and does
not supersede any behavioral or release-governing ADR.
