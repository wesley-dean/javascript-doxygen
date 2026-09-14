# Python Documentation Standard

The normative Python documentation standard adopted by this repository is the
managed copy at:

`doc/standards/python/documentation-standard.md`

That file is materialized from the concrete `coding_standards` release recorded in
`.codingstandardrc`.  Its canonical upstream is
`wesley-dean/coding_standards/standards/python/documentation-standard.md`.

The imported standard is authoritative for maintained Python content unless an
accepted repository-specific ADR or explicit local policy refines or supersedes
it.  Do not independently rewrite or weaken the imported contract.  Changes to
the shared standard belong upstream; project-specific exceptions belong in this
repository's governance.

The adopted standard establishes Python docstrings as the maintained source of
truth and uses triple-double-quoted docstrings with structured fields including:

```text
:param name: description
:returns: description
:raises ExceptionType: description
:yields: description
```

`python-doxygen` operates only at the documentation-generation boundary.  It
translates the explicitly supported subset into a Doxygen-facing representation
without requiring maintainers to keep a second Doxygen-specific documentation
dialect.

This adoption file is repository-specific guidance and is not a substitute for
the complete managed standard.
