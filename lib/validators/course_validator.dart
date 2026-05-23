// ============================================================
//  course_validator.dart  —  Course Form Validator
//
//  Following the same pattern as AppValidator from Part 1,
//  we keep all course-related validation rules in one place.
//  This way, if the rules change, we only edit this file.
//
//  SAME RULE AS BEFORE:
//    return null   → field is valid
//    return String → that string is the error message shown under the field
// ============================================================

class CourseValidator {
  // Private constructor — all methods are static, no need to instantiate
  CourseValidator._();

  // ----------------------------------------------------------------
  //  TITLE
  // ----------------------------------------------------------------
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Course title is required';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.trim().length > 100) {
      return 'Title must be under 100 characters';
    }
    return null; // valid
  }

  // ----------------------------------------------------------------
  //  BODY / DESCRIPTION
  // ----------------------------------------------------------------
  static String? validateBody(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null; // valid
  }
}
