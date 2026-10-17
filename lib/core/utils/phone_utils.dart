/// Helpers for turning local phone numbers into the international form
/// that WhatsApp, calls and SMS links need.
abstract final class PhoneUtils {
  /// "073 555 0178" -> "27735550178", "+27 73 555 0178" -> "27735550178".
  static String toInternational(String raw, {String countryCode = '27'}) {
    final trimmed = raw.trim();
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (trimmed.startsWith('+')) return digits;
    if (digits.startsWith('00')) return digits.substring(2);
    if (digits.startsWith('0')) return '$countryCode${digits.substring(1)}';
    return digits;
  }
}
