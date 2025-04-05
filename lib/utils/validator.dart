class Validators {
  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a price';
    }
    // Remove commas for validation
    final cleanValue = value.replaceAll(',', '');
    final number = double.tryParse(cleanValue);
    if (number == null || number <= 0) {
      return 'Please enter a valid positive number';
    }
    return null; // Valid
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter a $fieldName';
    }
    return null;
  }
}
