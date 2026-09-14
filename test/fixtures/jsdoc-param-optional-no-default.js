/**
 * Greet a user with an optional salutation.
 *
 * @param {string} [salutation] - Salutation placed before the name.
 */
function greet(salutation) {
  return `${salutation || "Hello"}, world!`;
}
