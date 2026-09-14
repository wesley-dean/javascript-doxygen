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
  in_virtual_typedef = 0
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

## @fn virtual_type_label(name)
## @brief Encodes a JavaScript identifier as a portable Doxygen page label.
## @details
## Encodes every identifier character into a lowercase alphanumeric token so
## labels remain deterministic and distinguish JavaScript case without requiring
## Doxygen case-sensitive page names.  `u` prefixes uppercase letters, `l`
## prefixes lowercase letters, `d` prefixes digits, `n0` represents underscore,
## and `s0` represents dollar sign.
##
## @param name Simple JavaScript identifier to encode.
## @local i Current one-based character position.
## @local character Current identifier character.
## @local label Encoded Doxygen page label.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns A lowercase alphanumeric page label for a supported identifier;
## otherwise an empty string.
function virtual_type_label(name,    i, character, label) {
  label = "jsdocvirtualtype"

  for (i = 1; i <= length(name); i++) {
    character = substr(name, i, 1)

    if (character ~ /^[A-Z]$/) {
      label = label "u" tolower(character)
    } else if (character ~ /^[a-z]$/) {
      label = label "l" character
    } else if (character ~ /^[0-9]$/) {
      label = label "d" character
    } else if (character == "_") {
      label = label "n0"
    } else if (character == "$") {
      label = label "s0"
    } else {
      return ""
    }
  }

  return label
}

## @fn virtual_callback_label(name)
## @brief Encodes a JavaScript callback identifier as a portable Doxygen page label.
## @details
## Uses the same character encoding as virtual typedef labels but a distinct
## namespace prefix so a typedef and callback with the same maintained name cannot
## collide in generated Doxygen documentation.
##
## @param name Simple JavaScript callback identifier to encode.
## @local i Current one-based character position.
## @local character Current identifier character.
## @local label Encoded Doxygen callback page label.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns A lowercase alphanumeric callback page label for a supported
## identifier; otherwise an empty string.
function virtual_callback_label(name,    i, character, label) {
  label = "jsdocvirtualcallback"

  for (i = 1; i <= length(name); i++) {
    character = substr(name, i, 1)

    if (character ~ /^[A-Z]$/) {
      label = label "u" tolower(character)
    } else if (character ~ /^[a-z]$/) {
      label = label "l" character
    } else if (character ~ /^[0-9]$/) {
      label = label "d" character
    } else if (character == "_") {
      label = label "n0"
    } else if (character == "$") {
      label = label "s0"
    } else {
      return ""
    }
  }

  return label
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

## @fn translate_throws(line)
## @brief Translates one canonical typed JSDoc `@throws` record.
## @details
## Recognizes the governed form `@throws {Type} Description.` when the exception
## type is a compact token without whitespace.  Doxygen expects an exception
## object immediately after `@throws`, so the filter removes only the JSDoc type
## braces and otherwise preserves the documented type and description text.
##
## @param line JSDoc source record to translate.
## @local prefix Leading indentation retained from the source record.
## @local work Scratch copy used while extracting fields.
## @local type Maintained JSDoc exception type without surrounding braces.
## @local description Maintained exception description.
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
function translate_throws(line,    prefix, work, type, description) {
  if (line !~ /^[[:space:]]*\*[[:space:]]+@throws[[:space:]]+\{[^}[:space:]]+\}[[:space:]]+.+$/) {
    return line
  }

  prefix = line
  sub(/\*.*/, "", prefix)

  work = line
  sub(/^[[:space:]]*\*[[:space:]]+@throws[[:space:]]+\{/, "", work)

  type = work
  sub(/\}.*/, "", type)

  description = work
  sub(/^[^}]*\}[[:space:]]+/, "", description)

  return prefix "* @throws " type " " description
}

## @fn translate_yields(line)
## @brief Translates one canonical typed JSDoc `@yields` record.
## @details
## Recognizes the governed form `@yields {Type} Description.` and emits the
## consumer-side `@jsyields` alias on the same physical source line.  The required
## Doxygen alias expands to a dedicated `Yields` paragraph during Doxygen parsing,
## preserving generator semantics without changing filter line correspondence.
##
## @param line JSDoc source record to translate.
## @local prefix Leading indentation retained from the source record.
## @local work Scratch copy used while extracting fields.
## @local type Maintained JSDoc yield type without surrounding braces.
## @local description Maintained yield description.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns A translated alias-backed record when the governed form matches;
## otherwise the original record unchanged.
function translate_yields(line,    prefix, work, type, description) {
  if (line !~ /^[[:space:]]*\*[[:space:]]+@yields[[:space:]]+\{[^}]+\}[[:space:]]+.+$/) {
    return line
  }

  prefix = line
  sub(/\*.*/, "", prefix)

  work = line
  sub(/^[[:space:]]*\*[[:space:]]+@yields[[:space:]]+\{/, "", work)

  type = work
  sub(/\}.*/, "", type)

  description = work
  sub(/^[^}]*\}[[:space:]]+/, "", description)

  return prefix "* @jsyields Type: " type ". " description
}

## @fn translate_typedef(line)
## @brief Translates one canonical virtual JSDoc `@typedef` record.
## @details
## Recognizes `@typedef {Type} Name` when Name is a simple JavaScript identifier.
## The generated `@jstypedef` command expands through consumer Doxygen aliases to
## a related page, giving the virtual documentation type a named link target
## without inventing a JavaScript declaration.  The base type remains textual.
##
## @param line JSDoc source record to translate.
## @local prefix Leading indentation retained from the source record.
## @local work Scratch copy used while extracting fields.
## @local type Maintained JSDoc base type without surrounding braces.
## @local name Maintained virtual type name.
## @local label Deterministic generated Doxygen page label.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns A translated alias-backed record when the governed form matches;
## otherwise the original record unchanged.
function translate_typedef(line,    prefix, work, type, name, label) {
  if (line !~ /^[[:space:]]*\*[[:space:]]+@typedef[[:space:]]+\{[^}]+\}[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*[[:space:]]*$/) {
    return line
  }

  prefix = line
  sub(/\*.*/, "", prefix)

  work = line
  sub(/^[[:space:]]*\*[[:space:]]+@typedef[[:space:]]+\{/, "", work)

  type = work
  sub(/\}.*/, "", type)

  if (type ~ /\|\|/) {
    return line
  }

  name = work
  sub(/^[^}]*\}[[:space:]]+/, "", name)
  sub(/[[:space:]]*$/, "", name)

  label = virtual_type_label(name)
  if (label == "") {
    return line
  }

  return prefix "* @jstypedef{" label "||" name "||" type "}"
}

## @fn translate_callback(line)
## @brief Translates one named JSDoc callback contract to a virtual page.
## @details
## Recognizes `@callback Name` when Name is a simple JavaScript identifier.  The
## generated `@jscallback` command creates a related page so the callback remains a
## named reusable documentation type without inventing a runtime JavaScript
## function declaration.  Governed parameter and return records in the same block
## retain their existing translations and are interpreted as callback-page
## documentation by Doxygen.
##
## @param line JSDoc source record to translate.
## @local prefix Leading indentation retained from the source record.
## @local name Maintained callback name.
## @local label Deterministic generated Doxygen callback page label.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns A translated alias-backed callback record when the governed form
## matches; otherwise the original record unchanged.
function translate_callback(line,    prefix, name, label) {
  if (line !~ /^[[:space:]]*\*[[:space:]]+@callback[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*[[:space:]]*$/) {
    return line
  }

  prefix = line
  sub(/\*.*/, "", prefix)

  name = line
  sub(/^[[:space:]]*\*[[:space:]]+@callback[[:space:]]+/, "", name)
  sub(/[[:space:]]*$/, "", name)

  label = virtual_callback_label(name)
  if (label == "") {
    return line
  }

  return prefix "* @jscallback{" label "||" name "}"
}

## @fn translate_property(line)
## @brief Translates one canonical JSDoc property of a governed virtual typedef.
## @details
## Recognizes `@property {Type} name - Description.` only after a supported
## virtual typedef has been established in the same JSDoc block.  Properties are
## rendered as structured paragraphs on the virtual type page rather than as fake
## JavaScript members or separately invented declarations.
##
## @param line JSDoc source record to translate.
## @local prefix Leading indentation retained from the source record.
## @local work Scratch copy used while extracting fields.
## @local type Maintained JSDoc property type without surrounding braces.
## @local name Maintained simple property name.
## @local description Maintained property description.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns A translated alias-backed property record when the governed form
## matches; otherwise the original record unchanged.
function translate_property(line,    prefix, work, type, name, description) {
  if (line !~ /^[[:space:]]*\*[[:space:]]+@property[[:space:]]+\{[^}]+\}[[:space:]]+[A-Za-z_$][A-Za-z0-9_$]*[[:space:]]+-[[:space:]]+.+$/) {
    return line
  }

  prefix = line
  sub(/\*.*/, "", prefix)

  work = line
  sub(/^[[:space:]]*\*[[:space:]]+@property[[:space:]]+\{/, "", work)

  type = work
  sub(/\}.*/, "", type)
  if (type ~ /\|\|/) {
    return line
  }

  sub(/^[^}]*\}[[:space:]]+/, "", work)

  name = work
  sub(/[[:space:]]+-.*/, "", name)

  description = work
  sub(/^[^[:space:]]+[[:space:]]+-[[:space:]]+/, "", description)
  if (description ~ /\|\|/) {
    return line
  }

  return prefix "* @jsproperty{" type "||" name "||" description "}"
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
      in_virtual_typedef = 0
    }
    next
  }

  if (is_jsdoc_close($0)) {
    print
    in_jsdoc = 0
    in_virtual_typedef = 0
    next
  }

  line = translate_param($0)
  line = translate_returns(line)
  line = translate_throws(line)
  line = translate_yields(line)
  line = translate_callback(line)

  translated_typedef = translate_typedef(line)
  if (translated_typedef != line) {
    in_virtual_typedef = 1
  }
  line = translated_typedef

  if (in_virtual_typedef) {
    line = translate_property(line)
  }

  print line
}
