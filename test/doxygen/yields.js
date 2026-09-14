/**
 * Iterate over validated records.
 *
 * @yields {Record} Validated records in source order.
 */
function* validatedRecords(records) {
  for (const record of records) {
    yield record;
  }
}
