import 'dart:io';
import 'package:cost_snap/features/widgets/edit_entry.dart';
import 'package:cost_snap/features/widgets/update_entry_form.dart';
import 'package:cost_snap/models/item.dart';
import 'package:cost_snap/theme/theme.dart';
import 'package:cost_snap/utils/const.dart';
import 'package:cost_snap/utils/storage.dart';
import 'package:cost_snap/utils/time_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DetailsScreen extends StatefulWidget {
  final Item item;
  final String currency;

  const DetailsScreen({super.key, required this.item, required this.currency});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Item _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  String _calculateTrend() {
    final history = _currentItem.priceHistory;
    if (history.length < 2) return 'Not enough data';
    final oldest = history.first.price;
    final latest = history.last.price;
    final change = ((latest - oldest) / oldest) * 100;
    return 'Price ${change >= 0 ? 'down' : 'up'} ${change.abs().toStringAsFixed(1)}%';
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.decimalPattern('en_US');
    final rate = AppConstants.exchangeRates[widget.currency] ?? 1.0;
    final convertedPrice = price * rate;
    return '${widget.currency == 'USD' ? '\$' : widget.currency == 'EUR' ? '€' : widget.currency == 'GBP' ? '£' : 'N'}${formatter.format(convertedPrice)}';
  }

  Future<void> _addNewEntry() async {
    Get.bottomSheet(
      _buildBottomSheet(
        title: 'Add New Entry',
        form: UpdateEntryForm(
          onSubmit: (price, location) async {
            setState(() {
              _currentItem = Item(
                id: _currentItem.id,
                name: _currentItem.name,
                photoPath: _currentItem.photoPath,
                priceHistory: [
                  PriceEntry(
                      price: price, location: location, date: DateTime.now()),
                  ..._currentItem.priceHistory,
                ],
                tag: _currentItem.tag,
              );
            });
            await _updateStorage();
            _showSnackbar(
                'Updated', 'New price added for ${_currentItem.name}');
          },
        ),
      ),
    );
  }

  Future<void> _editPriceEntry(PriceEntry entry) async {
    Get.bottomSheet(
      _buildBottomSheet(
        title: 'Edit Entry',
        form: EditEntryForm(
          onSubmit: (price, location) async {
            final previousItem = _currentItem;
            setState(() {
              _currentItem = Item(
                id: _currentItem.id,
                name: _currentItem.name,
                photoPath: _currentItem.photoPath,
                priceHistory: _currentItem.priceHistory.map((e) {
                  return e == entry
                      ? PriceEntry(
                          price: price, location: location, date: e.date)
                      : e;
                }).toList(),
                tag: _currentItem.tag,
              );
            });
            await _updateStorage();
            _showSnackbar(
              'Edited',
              'Price updated for ${_currentItem.name}',
              mainButton: TextButton(
                onPressed: () => _revertChanges(previousItem),
                child: const Text('Undo',
                    style: TextStyle(color: AppColors.background)),
              ),
            );
          },
          initialPrice: entry.price,
          initialLocation: entry.location,
        ),
      ),
    );
  }

  Future<void> _deletePriceEntry(PriceEntry entry) async {
    if (_currentItem.priceHistory.length <= 1) {
      _showSnackbar('Error', 'Cannot delete last entry',
          backgroundColor: Colors.red);
      return;
    }
    final previousItem = _currentItem;
    setState(() {
      _currentItem = Item(
        id: _currentItem.id,
        name: _currentItem.name,
        photoPath: _currentItem.photoPath,
        priceHistory:
            _currentItem.priceHistory.where((e) => e != entry).toList(),
        tag: _currentItem.tag,
      );
    });
    await _updateStorage();
    _showSnackbar(
      'Deleted',
      'Price entry removed',
      mainButton: TextButton(
        onPressed: () => _revertChanges(previousItem),
        child:
            const Text('Undo', style: TextStyle(color: AppColors.background)),
      ),
    );
  }

  Future<void> _updateStorage() async {
    final items = await Storage.loadItems();
    final updatedItems =
        items.map((i) => i.id == _currentItem.id ? _currentItem : i).toList();
    await Storage.saveItems(updatedItems);
  }

  Future<void> _revertChanges(Item previousItem) async {
    setState(() => _currentItem = previousItem);
    await _updateStorage();
    _showSnackbar('Undone', 'Changes reverted');
  }

  void _showSnackbar(String title, String message,
      {Color? backgroundColor, TextButton? mainButton}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor?.withOpacity(0.8) ??
          AppColors.accent.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      mainButton: mainButton,
    );
  }

  Widget _buildBottomSheet({required String title, required Widget form}) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumSpacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppConstants.smallSpacing),
              form,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.35,
            pinned: true,
            title: Text(_currentItem.name,
                style: const TextStyle(color: AppColors.background)),
            leading: IconButton(
              icon:
                  const Icon(CupertinoIcons.back, color: AppColors.background),
              onPressed: Get.back,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.file(
                File(_currentItem.photoPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(AppConstants.smallSpacing),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentItem.tag,
                          style: csTextTheme().bodyMedium?.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addNewEntry,
                        label: const Text('Add entry'),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.largeSpacing),
                  Text('Price Trend',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppConstants.smallSpacing),
                  Text(
                    _calculateTrend(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _currentItem.priceHistory.length < 2
                              ? AppColors.textSecondary
                              : _currentItem.priceHistory.last.price >
                                      _currentItem.priceHistory.first.price
                                  ? AppColors.accent
                                  : Colors.redAccent,
                        ),
                  ),
                  const SizedBox(height: AppConstants.largeSpacing),
                  Text('Price History',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppConstants.smallSpacing),
                  ..._currentItem.priceHistory.map(
                    (entry) => Dismissible(
                      key: Key(
                          '${entry.price}-${entry.date.millisecondsSinceEpoch}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(
                            right: AppConstants.mediumSpacing),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deletePriceEntry(entry),
                      child: GestureDetector(
                        onTap: () => _editPriceEntry(entry),
                        child: ListTile(
                          title: Text(
                            _formatPrice(entry.price),
                            style: csTextTheme().bodyLarge?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${entry.location} - ${getRelativeTime(entry.date)}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
