abstract final class Validators {
  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phoneRegExp = RegExp(r'^\+?[0-9\s-]{7,15}$');

  static const minPasswordLength = 6;

  static String? required(String? value, [String field = 'This field']) =>
      value == null || value.trim().isEmpty ? '$field is required' : null;

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Name is required';
    if (text.length < 3) return 'Name should be at least 3 characters';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    return _emailRegExp.hasMatch(text) ? null : 'Enter a valid email';
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < minPasswordLength) {
      return 'Password should be at least $minPasswordLength characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    return value == password ? null : 'Passwords do not match';
  }

  static String? optionalPhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return _phoneRegExp.hasMatch(text) ? null : 'Enter a valid phone number';
  }
}
