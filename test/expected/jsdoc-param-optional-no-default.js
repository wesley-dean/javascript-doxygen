/**
 * Greet a user with an optional salutation.
 *
 * @param salutation Salutation placed before the name. Type: string. Optional.
 */
function greet(salutation) {
  return `${salutation || "Hello"}, world!`;
}
