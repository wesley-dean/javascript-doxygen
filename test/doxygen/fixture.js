/**
 * Normalize a supplied value.
 *
 * @param {string} value - Value to normalize.
 * @param {boolean} [strict=true] - Whether invalid input is rejected.
 * @returns {string} The canonical normalized value.
 * @throws {TypeError} If `value` is not a string.
 */
function normalizeValue(value, strict) {
  if (strict && typeof value !== "string") {
    throw new TypeError("value must be a string");
  }

  return String(value).trim();
}
