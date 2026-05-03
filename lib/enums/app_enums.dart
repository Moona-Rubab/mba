// ============================================================
//  app_enums.dart  —  All enums live here
//
//  WHY ENUMS?
//  An enum is a special type that has a fixed set of named values.
//  Instead of using raw strings like "Male" / "Female" everywhere
//  (which can have typos), we use an enum so the compiler catches mistakes.
// ============================================================

// ---------- Gender ----------
// Used in the Registration form's dropdown
enum Gender {
  male,
  female,
  preferNotToSay,
}

// A handy helper so we can display a nice label in the UI
extension GenderLabel on Gender {
  String get label {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}

// ---------- AuthState ----------
// Represents what state the authentication flow is currently in.
// This is used inside the controller to track what's happening.
enum AuthState {
  idle, // Nothing happening — initial state
  loading, // We are processing (e.g., checking credentials)
  success, // Action succeeded
  error, // Something went wrong
}
