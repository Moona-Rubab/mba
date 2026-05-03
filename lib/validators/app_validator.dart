// ============================================================
//  app_validator.dart  —  Custom Validator Class
//
//  WHY A SEPARATE VALIDATOR CLASS?
//  Putting validation inside the UI widget makes it messy and hard
//  to reuse. By keeping all rules here, we can:
//    1. Call the same rule from multiple screens
//    2. Unit-test validation without running the UI
//    3. Change a rule in ONE place and it updates everywhere
//
//  HOW IT WORKS WITH FLUTTER FORMS:
//  Each TextFormField has a `validator` property.
//  Flutter calls that function when the form is submitted.
//  If it returns null  → field is valid ✅
//  If it returns a string → that string is shown as the error message ❌
// ============================================================

class AppValidator {
  // Private constructor — prevents anyone from doing `new AppValidator()`
  // All methods are static, so you call them as AppValidator.validateEmail(...)
  AppValidator._();

  // ----------------------------------------------------------------
  //  FULL NAME
  // ----------------------------------------------------------------
  static String? validateFullName(String? value) {
    // Trim removes leading/trailing spaces before checking
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null; // Valid!
  }

  // ----------------------------------------------------------------
  //  EMAIL
  // ----------------------------------------------------------------
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    // RegExp = Regular Expression — a pattern matcher for strings
    // This pattern checks for the classic  name@domain.tld  format
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email (e.g. user@example.com)';
    }
    return null;
  }

  // ----------------------------------------------------------------
  //  PASSWORD  (Registration — strong rules)
  // ----------------------------------------------------------------
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Check for at least one UPPERCASE letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least 1 uppercase letter';
    }

    // Check for at least one SPECIAL character  (anything not a letter or digit)
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least 1 special character';
    }

    return null;
  }

  // ----------------------------------------------------------------
  //  CONFIRM PASSWORD
  // ----------------------------------------------------------------
  // This validator needs the ORIGINAL password to compare against,
  // so we pass it in as a parameter.
  static String? validateConfirmPassword(
      String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please re-type your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ----------------------------------------------------------------
  //  LOGIN PASSWORD  (simpler — just required, no strength rules)
  // ----------------------------------------------------------------
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  // ----------------------------------------------------------------
  //  GENERIC REQUIRED FIELD  (reusable for any field)
  // ----------------------------------------------------------------
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
