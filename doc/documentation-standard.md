# JavaScript Documentation Standard Status

This repository has not yet adopted a normative JavaScript documentation standard.

The managed shared standards snapshot beneath `doc/standards/` currently contains
language-specific documentation standards for AWK, Bash, PHP, and Python, but no
JavaScript documentation standard.  Presence of those standards in the snapshot
does not make them applicable to maintained JavaScript source.

ADR-012 therefore keeps the current filter contract deliberately narrow:
`doxygen-javascript.awk` performs source pass-through only.  The project does not
yet claim support for any JSDoc tag grammar, type-expression syntax, inline tag,
module convention, callback form, typedef form, or Doxygen-facing translation.

The intended architectural direction is to keep maintained JavaScript documentation
JavaScript-native and perform any required compatibility translation at the
Doxygen boundary.  That direction is not a substitute for a normative standard.
A future JavaScript documentation standard should define the maintained source
contract before the filter claims corresponding translation behavior.

Maintained AWK implementation source is governed by:

`doc/standards/awk/documentation-standard.md`

Shared-standard changes belong upstream in `wesley-dean/coding_standards`.
Repository-specific exceptions or transition decisions belong in accepted local
ADRs rather than edits beneath `doc/standards/`.
