#!/usr/bin/awk -f
## @file doxygen-javascript.awk
## @brief Provides the bootstrap Doxygen input filter for JavaScript.
## @details
## Milestone 1 deliberately performs no JSDoc translation.  Every input record is
## written unchanged so the project can establish its executable filter and test
## contracts before adding documentation transformations.

## @rule pass_through_source
## @brief Writes the current JavaScript source record unchanged.
##
## @par STDIN
## Reads JavaScript source records supplied by AWK.
## @par STDOUT
## Writes each input record followed by the input record separator.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns Nothing is returned; the rule writes the current record to STDOUT.
{
  print
}
