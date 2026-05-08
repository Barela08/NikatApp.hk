class Validators {
  Validators._();

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid 10-digit phone number';
    return null;
  }

  static String? aadhaar(String? value) {
    if (value == null || value.isEmpty) return 'Aadhaar number is required';
    final digits = value.replaceAll(' ', '');
    if (digits.length != 12) return 'Aadhaar must be 12 digits';
    if (!RegExp(r'^\d{12}$').hasMatch(digits)) return 'Aadhaar must contain only numbers';
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null; // email is optional
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (value.trim().length > 60) return 'Name is too long';
    return null;
  }

  static String? pincode(String? value) {
    if (value == null || value.isEmpty) return 'Pincode is required';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'Enter a valid 6-digit pincode';
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.isEmpty) return null;
    final n = double.tryParse(value);
    if (n == null) return 'Enter a valid price';
    if (n < 0) return 'Price cannot be negative';
    if (n > 1000000) return 'Price seems too high';
    return null;
  }

  static String? upi(String? value) {
    if (value == null || value.isEmpty) return 'UPI ID is required';
    if (!RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z]+$').hasMatch(value)) {
      return 'Enter a valid UPI ID (e.g., name@upi)';
    }
    return null;
  }
}
