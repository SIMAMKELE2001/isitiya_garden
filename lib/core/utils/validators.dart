/// Input rules used by the forms. Each returns an error message,
/// or null when the value is fine (this is what Flutter forms expect).
/// The phone rule matches the CHECK constraint in the database.
abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phone = RegExp(r'^\+?[0-9 ]{9,15}$');

  static String? notEmpty(String? value, [String label = 'This field']) =>
      (value == null || value.trim().isEmpty) ? '$label is required.' : null;

  static String? fullName(String? value) {
    final empty = notEmpty(value, 'Your name');
    if (empty != null) return empty;
    return value!.trim().length < 2 ? 'Enter your full name.' : null;
  }

  static String? email(String? value) {
    final empty = notEmpty(value, 'Email');
    if (empty != null) return empty;
    return _email.hasMatch(value!.trim())
        ? null
        : 'Enter a valid email address, like name@example.com.';
  }

  static String? phone(String? value) {
    final empty = notEmpty(value, 'Phone number');
    if (empty != null) return empty;
    return _phone.hasMatch(value!.trim())
        ? null
        : 'Enter a valid phone number, for example 072 555 0142.';
  }

  static String? password(String? value) {
    final empty = notEmpty(value, 'Password');
    if (empty != null) return empty;
    return value!.length < 6 ? 'Use at least 6 characters.' : null;
  }
}
