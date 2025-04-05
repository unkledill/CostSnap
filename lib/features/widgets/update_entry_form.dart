import 'package:cost_snap/theme/theme.dart';
import 'package:cost_snap/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UpdateEntryForm extends StatefulWidget {
  final Function(double price, String location) onSubmit;
  final double? initialPrice;
  final String? initialLocation;

  const UpdateEntryForm({
    super.key,
    required this.onSubmit,
    this.initialPrice,
    this.initialLocation,
  });

  @override
  _UpdateEntryFormState createState() => _UpdateEntryFormState();
}

class _UpdateEntryFormState extends State<UpdateEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  late String _location;
  final NumberFormat _numberFormat = NumberFormat.decimalPattern('en_US');

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.initialPrice != null
        ? _numberFormat.format(widget.initialPrice!)
        : ''; // Format initial price with commas
    _location = widget.initialLocation ?? '';
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            showCursor: true,
            cursorWidth: 5,
            cursorColor: AppColors.textPrimary,
            controller: _priceController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.textPrimary),
              ),
              hintText: 'New Price',
              hintStyle: TextStyle(color: Colors.black45),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Only numbers
              _NumberTextInputFormatter(), // Add commas as you type
            ],
            validator: Validators.price,
            onSaved: (value) => _priceController.text = value!,
          ),
          SizedBox(height: 16),
          TextFormField(
            showCursor: true,
            cursorWidth: 5,
            cursorColor: AppColors.textPrimary,
            initialValue: widget.initialLocation,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.textPrimary),
              ),
              hintText: 'Location',
              hintStyle: TextStyle(color: Colors.black45),
              border: OutlineInputBorder(),
            ),
            validator: (value) => Validators.required(value, 'location'),
            onSaved: (value) => _location = value!,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final price =
                    double.parse(_priceController.text.replaceAll(',', ''));
                widget.onSubmit(price, _location);
                Get.back();
              }
            },
            child: Text(
              widget.initialPrice == null
                  ? 'Add Entry'
                  : 'Save Changes', // Fixed button text logic
            ),
          ),
        ],
      ),
    );
  }
}

// Custom formatter to add commas as you type
class _NumberTextInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('en_US');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final number = double.tryParse(newValue.text.replaceAll(',', ''));
    if (number == null) {
      return oldValue; // Invalid input, revert to old value
    }
    final formatted = _formatter.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
