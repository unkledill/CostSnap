import 'dart:io';
import 'package:cost_snap/utils/number_formater.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/theme.dart';
import '../../utils/validator.dart';

class ItemForm extends StatefulWidget {
  final Function(
          String name, double price, String location, File photo, String tag)
      onSubmit;

  const ItemForm({super.key, required this.onSubmit});

  @override
  _ItemFormState createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _price = 0.0;
  String _location = '';
  File? _photo;
  String _tag = 'Grocery';
  final List<String> _tags = ['Grocery', 'Stationary', 'Consumables', 'Others'];
  final picker = ImagePicker();

  Future<void> _takePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) setState(() => _photo = File(pickedFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: _takePhoto,
              child: Container(
                height: 200,
                width: double.infinity,
                color: AppColors.background,
                child: _photo != null
                    ? Image.file(_photo!, fit: BoxFit.cover)
                    : Center(
                        child: Text('Tap to take a photo',
                            style: Theme.of(context).textTheme.bodyLarge)),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => Validators.required(value, 'item name'),
              onSaved: (value) => _name = value!,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                  prefixText: '\$',
                  // labelText: 'Price',
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [NumberTextInputFormatter()],
              validator: Validators.price,
              onSaved: (value) => _price = double.parse(value!),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Location', border: OutlineInputBorder()),
              validator: (value) => Validators.required(value, 'location'),
              onSaved: (value) => _location = value!,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tag,
              decoration: InputDecoration(
                  labelText: 'Tag', border: OutlineInputBorder()),
              items: _tags
                  .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
                  .toList(),
              onChanged: (value) => setState(() => _tag = value!),
              validator: (value) => Validators.required(value, 'tag'),
              onSaved: (value) => _tag = value!,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && _photo != null) {
                  _formKey.currentState!.save();
                  widget.onSubmit(_name, _price, _location, _photo!, _tag);
                } else if (_photo == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please take a photo')));
                }
              },
              child: Text('Save Item'),
            ),
          ],
        ),
      ),
    );
  }
}
