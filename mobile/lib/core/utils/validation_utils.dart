class ValidationUtils {
  // RFC 5322 compliant regex for strict email validation
  static final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?$",
  );

  // E.164 international phone number format: + followed by 7 to 15 digits
  static final RegExp _phoneRegExp = RegExp(
    r"^\+?[1-9]\d{7,14}$",
  );

  /// Validates email format and rejects dummy domains or missing TLDs
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Please enter a valid email address (e.g. name@company.com)';
    }
    // Basic domain check: domain must have at least one dot and a 2+ char TLD
    final parts = trimmed.split('@');
    if (parts.length != 2 || !parts[1].contains('.')) {
      return 'Email must include a valid domain name';
    }
    final domainParts = parts[1].split('.');
    if (domainParts.any((part) => part.isEmpty)) {
      return 'Invalid domain structure';
    }
    return null;
  }

  /// Validates international phone format (required for WhatsApp delivery)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required for WhatsApp task notifications';
    }
    // Remove common user formatting like spaces, dashes, parentheses
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!_phoneRegExp.hasMatch(cleaned)) {
      return 'Please include country code (e.g. +14155552671 or +919876543210)';
    }
    return null;
  }

  /// Cleans phone number to standard international format (+1234567890)
  static String cleanPhone(String value) {
    final digitsAndPlus = value.replaceAll(RegExp(r'[^\d+]'), '');
    if (!digitsAndPlus.startsWith('+')) {
      return '+$digitsAndPlus';
    }
    return digitsAndPlus;
  }

  /// Validates strong password rules: min 6 chars (Firebase minimum is 6)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  /// Validates confirm password matches password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
