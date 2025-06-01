class Validators {
  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a price';
    }
    final cleanValue = value.replaceAll(',', '');
    final number = double.tryParse(cleanValue);
    if (number == null || number <= 0) {
      return 'Enter a valid positive price';
    }
    if (number > 1000000000) {
      return 'Price is too large';
    }
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Enter the $fieldName';
    }
    return null;
  }
}
