import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumberTextInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter =
      NumberFormat.decimalPattern('en_US'); // Comma separator

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove non-numeric characters except decimal point
    String cleaned = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Parse and format the number
    double? value = double.tryParse(cleaned);
    if (value == null) {
      return oldValue; // Invalid input, revert to old value
    }

    String formatted = _formatter.format(value);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // Utility to parse formatted string back to double
  static double parse(String formatted) {
    String cleaned = formatted.replaceAll(',', '');
    return double.parse(cleaned);
  }
}
