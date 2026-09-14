#!/usr/bin/awk -f
## @file doxygen-javascript.awk
## @brief Translates supported JSDoc forms for Doxygen.
## @details
## Preserves JavaScript source and rewrites only explicitly governed JSDoc forms
## inside conservatively recognized documentation blocks.  Unsupported or
## ambiguous forms remain visible rather than receiving speculative semantics.

## @rule initialize_filter
## @brief Initializes documentation-block parser state.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns Nothing is returned; the rule initializes global parser state.
BEGIN {
  in_jsdoc = 0
}

## @fn is_jsdoc_open(line)
## @brief Tests whether a source record opens a supported JSDoc block.
##
## @param line Source record to inspect.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns 1 when the record contains only optional indentation and `/**`;
## otherwise 0.
function is_jsdoc_open(line) {
  return line ~ /^[[:space:]]*\/\*\*[[:space:]]*$/
}

## @fn is_jsdoc_close(line)
## @brief Tests whether a source record closes a supported JSDoc block.
##
## @param line Source record to inspect.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns 1 when the record contains only optional indentation and `*/`;
## otherwise 0.
function is_jsdoc_close(line) {
  return line ~ /^[[:space:]]*\*\/[[:space:]]*$/
}

## @fn translate_required_param(line)
## @brief Translates one canonical required JSDoc `@param` record.
## @details
## Recognizes only the governed form `@param {Type} name - Description.` where
## `name` is a simple JavaScript identifier.  The type expression is preserved as
## visible Doxygen-facing prose rather than interpreted semantically.
##
## @param line JSDoc source record to translate.
## @local prefix Leading indentation retained from the source record.
## @local work Scratch copy used while extracting fields.
## @local type Maintained JSDoc type expression without surrounding braces.
## @local name Required parameter identifier.
## @local description Maintained parameter description.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns A translated Doxygen-facing record when the governed form matches;
## otherwise the original record unchanged.
function translate_required_param(line,    prefix, work, type, name, description) {
  if (line !~ /^[[:space:]]*\*[[:space:]]+@param[[:space:]]+\{[^}]+\}[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*[[:space:]]+-[[:space:]]+.+$/) {
    return line
  }

  prefix = line
  sub(/\*.*/, "", prefix)

  work = line
  sub(/^[[:space:]]*\*[[:space:]]+@param[[:space:]]+\{/, "", work)

  type = work
  sub(/\}.*/, "", type)

  sub(/^[^}]*\}[[:space:]]+/, "", work)

  name = work
  sub(/[[:space:]]+-.*/, "", name)

  description = work
  sub(/^[^[:space:]]+[[:space:]]+-[[:space:]]+/, "", description)

  return prefix "* @param " name " " description " Type: " type "."
}

## @rule filter_source
## @brief Preserves JavaScript source while translating governed JSDoc records.
##
## @par STDIN
## Reads JavaScript source records supplied by AWK.
## @par STDOUT
## Writes one output record for every input record.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns Nothing is returned; the rule writes the filtered record to STDOUT.
{
  if (!in_jsdoc) {
    print
    if (is_jsdoc_open($0)) {
      in_jsdoc = 1
    }
    next
  }

  if (is_jsdoc_close($0)) {
    print
    in_jsdoc = 0
    next
  }

  print translate_required_param($0)
}
