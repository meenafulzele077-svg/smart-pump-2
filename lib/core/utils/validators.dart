/// Simple, dependency-free form validators used across auth & profile forms.
class Validators {
  Validators._();

  static String? mobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? mpin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'MPIN is required';
    }
    if (value.length != 4 && value.length != 6) {
      return 'MPIN must be 4 or 6 digits';
    }
    return null;
  }

  static String? notEmpty(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field cannot be empty';
    }
    return null;
  }
}
