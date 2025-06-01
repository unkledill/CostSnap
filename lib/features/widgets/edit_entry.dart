// import 'package:cost_snap/theme/theme.dart';

import 'package:cost_snap/utils/formatters.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../utils/const.dart';
import '../../utils/validators.dart';

class EditEntryForm extends StatefulWidget {
  final Function(double price, String location) onSubmit;
  final double initialPrice;
  final String initialLocation;

  const EditEntryForm({
    super.key,
    required this.onSubmit,
    required this.initialPrice,
    required this.initialLocation,
  });

  @override
  _EditEntryFormState createState() => _EditEntryFormState();
}

class _EditEntryFormState extends State<EditEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  late String _location;
  final NumberFormat _numberFormat = NumberFormat.decimalPattern('en_US');

  @override
  void initState() {
    super.initState();
    _priceController.text = _numberFormat.format(widget.initialPrice);
    _location = widget.initialLocation;
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(
              prefix: Text('N'),
              hintText: 'Price',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              NumberTextInputFormatter(),
            ],
            validator: Validators.price,
            cursorWidth: screenWidth * 0.005,
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          TextFormField(
            initialValue: widget.initialLocation,
            decoration: const InputDecoration(
              hintText: 'Location',
            ),
            validator: (value) => Validators.required(value, 'location'),
            onSaved: (value) => _location = value!,
            cursorWidth: screenWidth * 0.005,
          ),
          const SizedBox(height: AppConstants.largeSpacing),
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
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
