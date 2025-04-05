import 'dart:io';
import 'package:cost_snap/theme/theme.dart';
import 'package:cost_snap/utils/validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddItemScreen extends StatefulWidget {
  final Function(
          String name, double price, String location, File photo, String tag)
      onItemAdded;
  final File? initialPhoto; // Made nullable to handle no initial photo

  const AddItemScreen(
      {super.key, required this.onItemAdded, this.initialPhoto});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  final _priceController = TextEditingController();
  String _location = '';
  String _tag = 'Grocery';
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _photo = widget.initialPhoto; // Set initial photo if provided
  }

  Future<void> _takePhoto() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  void _deletePhoto() {
    setState(() {
      _photo = null;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _photo != null) {
      _formKey.currentState!.save();
      final price = double.parse(_priceController.text.replaceAll(',', ''));
      widget.onItemAdded(_name, price, _location, _photo!, _tag);
      Get.back();
    } else if (_photo == null) {
      Get.snackbar('Error', 'Please take a photo',
          backgroundColor: AppColors.accent.withOpacity(0.8));
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snap an Item',
            style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: AppColors.textPrimary),
          onPressed: Get.back,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Section
              _photo == null
                  ? GestureDetector(
                      onTap: _takePhoto,
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.photo,
                            size: 120,
                            color: const Color.fromARGB(193, 117, 117, 117),
                          ),
                        ),
                      ),
                    )
                  : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _photo!,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 14,
                          top: 14,
                          child: IconButton(
                            onPressed: _deletePhoto,
                            icon: Icon(Icons.delete),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 24),

              // Name Field
              TextFormField(
                showCursor: true,
                cursorWidth: 5,
                cursorColor: AppColors.textPrimary,
                decoration: InputDecoration(
                  hintText: 'Item Name',
                  hintStyle: TextStyle(color: Colors.black45),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black45),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.textPrimary),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => Validators.required(value, 'name'),
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: 16),

              // Price Field
              TextFormField(
                controller: _priceController,
                showCursor: true,
                cursorWidth: 5,
                cursorColor: AppColors.textPrimary,
                decoration: InputDecoration(
                  hintText: 'Price',
                  hintStyle: TextStyle(color: Colors.black45),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.textPrimary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black45),
                  ),
                  prefix: Text('N'),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _NumberTextInputFormatter(),
                ],
                validator: Validators.price,
                onSaved: (value) => _priceController.text = value!,
              ),
              SizedBox(height: 16),

              // Location Field
              TextFormField(
                showCursor: true,
                cursorWidth: 5,
                cursorColor: AppColors.textPrimary,
                decoration: InputDecoration(
                  hintText: 'Location',
                  hintStyle: TextStyle(color: Colors.black45),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.textPrimary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black45),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => Validators.required(value, 'location'),
                onSaved: (value) => _location = value!,
              ),
              Gap(20),

              // Tag Dropdown
              DropdownMenu<String>(
                label: Text('Tags'),
                initialSelection: _tag,
                width: MediaQuery.of(context).size.width - 32,
                dropdownMenuEntries: [
                  'Grocery',
                  'Consumables',
                  'Stationary',
                  'Others'
                ]
                    .map((tag) =>
                        DropdownMenuEntry<String>(value: tag, label: tag))
                    .toList(),
                inputDecorationTheme: InputDecorationTheme(
                  labelStyle: TextStyle(color: Colors.black45),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black45),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black45),
                  ),
                ),
                onSelected: (value) => setState(() => _tag = value!),
              ),
              SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: AppColors.primary,
                ),
                child: Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberTextInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('en_US');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final number = double.tryParse(newValue.text.replaceAll(',', ''));
    if (number == null) return oldValue;
    final formatted = _formatter.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
