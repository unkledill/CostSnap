import 'dart:io';
import 'package:cost_snap/theme/theme.dart';

import 'package:cost_snap/utils/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../utils/const.dart';

class AddItemScreen extends StatefulWidget {
  final Function(
          String name, double price, String location, File photo, String tag)
      onItemAdded;
  final File? initialPhoto;

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
    _photo = widget.initialPhoto;
  }

  Future<void> _takePhoto() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _photo = File(pickedFile.path));
    }
  }

  void _deletePhoto() {
    setState(() => _photo = null);
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
    final textTheme = csTextTheme();
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Snap an Item'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoSection(context, screenHeight),
              const SizedBox(height: AppConstants.largeSpacing),
              _buildNameField(context, textTheme),
              const SizedBox(height: AppConstants.mediumSpacing),
              _buildPriceField(context, textTheme),
              const SizedBox(height: AppConstants.mediumSpacing),
              _buildLocationField(context, textTheme),
              const SizedBox(height: AppConstants.largeSpacing),
              _buildTagDropdown(context, textTheme),
              const SizedBox(height: AppConstants.largeSpacing),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context, double screenHeight) {
    return _photo == null
        ? GestureDetector(
            onTap: _takePhoto,
            child: Container(
              height: screenHeight * 0.3,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.photo,
                      size: 60,
                      color: Color.fromARGB(193, 117, 117, 117),
                    ),
                    Text('Take Photo'),
                  ],
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
                  height: screenHeight * 0.3,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 14,
                top: 14,
                child: IconButton(
                  onPressed: _deletePhoto,
                  icon: const Icon(Icons.delete),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildNameField(BuildContext context, TextTheme textTheme) {
    return TextFormField(
      initialValue: _name,
      decoration: InputDecoration(
        hintText: 'Item Name',
        hintStyle:
            textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => Validators.required(value, 'name'),
      onSaved: (value) => _name = value!,
    );
  }

  Widget _buildPriceField(BuildContext context, TextTheme textTheme) {
    return TextFormField(
      controller: _priceController,
      decoration: InputDecoration(
        hintText: 'Price',
        hintStyle:
            textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        prefix: const Text('N'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _NumberTextInputFormatter(),
      ],
      validator: Validators.price,
    );
  }

  Widget _buildLocationField(BuildContext context, TextTheme textTheme) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Location',
        hintStyle:
            textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => Validators.required(value, 'location'),
      onSaved: (value) => _location = value!,
    );
  }

  Widget _buildTagDropdown(BuildContext context, TextTheme textTheme) {
    return DropdownMenu<String>(
      label: Text('Tags',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
      initialSelection: _tag,
      width: MediaQuery.of(context).size.width - 32,
      dropdownMenuEntries: ['Grocery', 'Consumables', 'Stationary', 'Others']
          .map((tag) => DropdownMenuEntry<String>(
                value: tag,
                label: tag,
                style: MenuItemButton.styleFrom(
                  foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                  textStyle: textTheme.bodyLarge,
                ),
              ))
          .toList(),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      menuStyle: MenuStyle(
        backgroundColor:
            WidgetStateProperty.all(Theme.of(context).colorScheme.surface),
        elevation: const WidgetStatePropertyAll(4),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      onSelected: (value) => setState(() => _tag = value!),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: AppColors.primary,
      ),
      child: const Text('Add Item'),
    );
  }
}

class _NumberTextInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('en_US');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final number = double.tryParse(newValue.text.replaceAll(',', '')) ?? 0;
    final formatted = _formatter.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
