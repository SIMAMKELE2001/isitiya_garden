/// Input rules for the Add / Edit produce form (NFR04).
/// They mirror the CHECK constraints in the database.
abstract final class ListingValidators {
  /// Accepts "12.5" and "12,5" (South African keyboards use a comma).
  static double? parseNumber(String? raw) {
    if (raw == null) return null;
    return double.tryParse(raw.trim().replaceAll(',', '.'));
  }

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Produce name is required.';
    if (text.length < 2) return 'Enter at least 2 letters.';
    return null;
  }

  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) return 'Quantity is required.';
    final n = parseNumber(value);
    if (n == null || n <= 0) return 'Enter an amount above 0, for example 20.';
    return null;
  }

  /// A price is needed unless the farmer marks it negotiable (FR09).
  static String? price(String? value, {required bool isRequired}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return isRequired
          ? 'Enter a price, or switch on "Price is negotiable".'
          : null;
    }
    final n = parseNumber(text);
    if (n == null || n < 0) return 'Enter a price like 12 or 12.50.';
    return null;
  }

  static String? description(String? value) =>
      (value != null && value.trim().length > 600)
          ? 'Keep this under 600 characters.'
          : null;

  static String? locationNote(String? value) =>
      (value != null && value.trim().length > 120)
          ? 'Keep this under 120 characters.'
          : null;

  static String? about(String? value) =>
      (value != null && value.trim().length > 500)
          ? 'Keep this under 500 characters.'
          : null;
}
