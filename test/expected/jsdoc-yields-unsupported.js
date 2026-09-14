/**
 * Iterate over records with unsupported yields forms.
 *
 * @yields Validated records in source order.
 * @yields {Record}
 */
function* records() {
  yield { id: 1 };
}
