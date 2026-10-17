import 'package:supabase_flutter/supabase_flutter.dart';

/// Turns technical errors into short messages a farmer or buyer can act on.
String friendlyAuthError(Object error) {
  if (error is AuthException) {
    final m = error.message.toLowerCase();
    if (m.contains('invalid login')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (m.contains('already registered') || m.contains('already exists')) {
      return 'An account with this email already exists. Try logging in.';
    }
    if (m.contains('database error')) {
      return 'We could not create your account. Check your details and try again.';
    }
    if (m.contains('password')) {
      return 'Choose a password with at least 6 characters.';
    }
    return 'We could not complete that. Please try again.';
  }
  return 'Something went wrong. Please check your connection and try again.';
}
