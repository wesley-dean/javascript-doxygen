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

## @fn translate_param(line)
## @brief Translates one governed JSDoc `@param` record.
## @details
## Recognizes canonical required parameters, optional parameters, and optional
## parameters with documented defaults when the parameter name is a simple
## JavaScript identifier.  Type and default expressions are preserved textually
## as visible Doxygen-facing prose rather than interpreted semantically.
##
## @param line JSDoc source record to translate.
## @local prefix Leading indentation retained from the source record.
## @local work Scratch copy used while extracting fields.
## @local type Maintained JSDoc type expression without surrounding braces.
## @local token Maintained parameter token between the type and description.
## @local name Parameter identifier emitted to Doxygen.
## @local description Maintained parameter description.
## @local body Optional parameter token without surrounding brackets.
## @local default_value Maintained documented default expression, when present.
## @local equals_index Position of the first equals sign in an optional token.
## @local optional 1 when the parameter is optional; otherwise 0.
## @local has_default 1 when an optional parameter documents a default.
## @local result Doxygen-facing translated record.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns A translated Doxygen-facing record when a governed form matches;
## otherwise the original record unchanged.
function translate_param(line,    prefix, work, type, token, name, description, body, default_value, equals_index, optional, has_default, result) {
  if (line !~ /^[[:space:]]*\*[[:space:]]+@param[[:space:]]+\{[^}]+\}[[:space:]]+[^[:space:]]+[[:space:]]+-[[:space:]]+.+$/) {
    return line
  }

  prefix = line
  sub(/\*.*/, "", prefix)

  work = line
  sub(/^[[:space:]]*\*[[:space:]]+@param[[:space:]]+\{/, "", work)

  type = work
  sub(/\}.*/, "", type)

  sub(/^[^}]*\}[[:space:]]+/, "", work)

  token = work
  sub(/[[:space:]]+-.*/, "", token)

  description = work
  sub(/^[^[:space:]]+[[:space:]]+-[[:space:]]+/, "", description)

  optional = 0
  has_default = 0
  default_value = ""

  if (token ~ /^[A-Za-z_$][A-Za-z0-9_$]*$/) {
    name = token
  } else if (token ~ /^\[[A-Za-z_$][A-Za-z0-9_$]*\]$/) {
    optional = 1
    name = token
    sub(/^\[/, "", name)
    sub(/\]$/, "", name)
  } else if (token ~ /^\[[A-Za-z_$][A-Za-z0-9_$]*=[^]]+\]$/) {
    optional = 1
    has_default = 1
    body = token
    sub(/^\[/, "", body)
    sub(/\]$/, "", body)
    equals_index = index(body, "=")
    name = substr(body, 1, equals_index - 1)
    default_value = substr(body, equals_index + 1)
  } else {
    return line
  }

  result = prefix "* @param " name " " description " Type: " type "."

  if (optional) {
    result = result " Optional."
  }

  if (has_default) {
    result = result " Default: " default_value "."
  }

  return result
}

## @fn translate_returns(line)
## @brief Translates one canonical typed JSDoc `@returns` record.
## @details
## Recognizes only the governed form `@returns {Type} Description.` inside a
## supported JSDoc block.  Doxygen already recognizes `@returns`, so the filter
## retains that command while moving the JSDoc type expression into visible prose.
##
## @param line JSDoc source record to translate.
## @local prefix Leading indentation retained from the source record.
## @local work Scratch copy used while extracting fields.
## @local type Maintained JSDoc type expression without surrounding braces.
## @local description Maintained return-value description.
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
function translate_returns(line,    prefix, work, type, description) {
  if (line !~ /^[[:space:]]*\*[[:space:]]+@returns[[:space:]]+\{[^}]+\}[[:space:]]+.+$/) {
    return line
  }

  prefix = line
  sub(/\*.*/, "", prefix)

  work = line
  sub(/^[[:space:]]*\*[[:space:]]+@returns[[:space:]]+\{/, "", work)

  type = work
  sub(/\}.*/, "", type)

  description = work
  sub(/^[^}]*\}[[:space:]]+/, "", description)

  return prefix "* @returns " description " Type: " type "."
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

  line = translate_param($0)
  print translate_returns(line)
}
