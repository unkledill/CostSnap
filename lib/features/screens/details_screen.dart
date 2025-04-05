import 'dart:io';
import 'package:cost_snap/features/widgets/edit_entry.dart';
import 'package:cost_snap/utils/storage.dart';
import 'package:cost_snap/utils/time_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/item.dart';
import '../../theme/theme.dart';
import '../widgets/update_entry_form.dart';

class DetailsScreen extends StatefulWidget {
  final Item item;
  final bool showInUSD; // Add showInUSD parameter

  const DetailsScreen({super.key, required this.item, required this.showInUSD});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Item _currentItem;
  static const double _exchangeRate = 1645.0; // Match HomeScreen

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  String _calculateTrend() {
    if (_currentItem.priceHistory.length < 2) return 'Not enough data yet';
    final oldest = _currentItem.priceHistory.first.price;
    final latest = _currentItem.priceHistory.last.price;
    final change = ((latest - oldest) / oldest) * 100;
    final direction = change >= 0 ? 'down' : 'up';
    return 'Price $direction ${change.abs().toStringAsFixed(1)}% since first snap';
  }

  String _formatPrice(double price) {
    final NumberFormat formatter = NumberFormat.decimalPattern('en_US');
    if (widget.showInUSD) {
      return '\$${formatter.format(price / _exchangeRate)}'; // e.g., "$0.31"
    }
    return 'N${formatter.format(price)}'; // e.g., "₦300,000"
  }

  Future<void> _addNewEntry() async {
    Get.bottomSheet(
      BottomSheet(
        onClosing: () {},
        builder: (context) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add New Entry',
                  style: csTextTheme()
                      .titleLarge
                      ?.copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 10),
                UpdateEntryForm(
                  onSubmit: (price, location) async {
                    // final previousItem = _currentItem;
                    setState(() {
                      _currentItem = Item(
                        id: _currentItem.id,
                        name: _currentItem.name,
                        photoPath: _currentItem.photoPath,
                        priceHistory: [
                          PriceEntry(
                              price: price,
                              location: location,
                              date: DateTime.now()),
                          ..._currentItem.priceHistory,
                        ],
                        tag: _currentItem.tag,
                      );
                    });
                    final items = await Storage.loadItems();
                    final updatedItems = items
                        .map((i) => i.id == _currentItem.id ? _currentItem : i)
                        .toList();
                    await Storage.saveItems(updatedItems);
                    Get.snackbar(
                      'Updated',
                      'New price added for ${_currentItem.name}',
                      colorText: Colors.white,
                      backgroundColor: AppColors.accent.withOpacity(0.8),
                      snackPosition: SnackPosition.TOP,
                      duration: Duration(seconds: 2),
                      // mainButton: TextButton(
                      //   onPressed: () async {
                      //     setState(() => _currentItem = previousItem);
                      //     final items = await Storage.loadItems();
                      //     final revertedItems = items
                      //         .map((i) =>
                      //             i.id == _currentItem.id ? _currentItem : i)
                      //         .toList();
                      //     await Storage.saveItems(revertedItems);
                      //     Get.snackbar('Undone', 'Price entry removed',
                      //         backgroundColor:
                      //             AppColors.accent.withOpacity(0.8));
                      //   },
                      //   child: Text('Undo',
                      //       style: TextStyle(color: AppColors.background)),
                      // ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editPriceEntry(PriceEntry entry) async {
    Get.bottomSheet(
      BottomSheet(
        onClosing: () {},
        builder: (context) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Entry',
                  style: csTextTheme()
                      .titleLarge
                      ?.copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 10),
                EditEntryForm(
                  onSubmit: (price, location) async {
                    final previousItem = _currentItem;
                    setState(() {
                      _currentItem = Item(
                        id: _currentItem.id,
                        name: _currentItem.name,
                        photoPath: _currentItem.photoPath,
                        priceHistory: _currentItem.priceHistory.map((e) {
                          if (e == entry) {
                            return PriceEntry(
                                price: price, location: location, date: e.date);
                          }
                          return e;
                        }).toList(),
                        tag: _currentItem.tag,
                      );
                    });
                    final items = await Storage.loadItems();
                    final updatedItems = items
                        .map((i) => i.id == _currentItem.id ? _currentItem : i)
                        .toList();
                    await Storage.saveItems(updatedItems);
                    Get.snackbar(
                      'Edited',
                      'Price entry updated for ${_currentItem.name}',
                      backgroundColor: AppColors.accent.withOpacity(0.8),
                      snackPosition: SnackPosition.BOTTOM,
                      duration: Duration(seconds: 2),
                      mainButton: TextButton(
                        onPressed: () async {
                          setState(() => _currentItem = previousItem);
                          final items = await Storage.loadItems();
                          final revertedItems = items
                              .map((i) =>
                                  i.id == _currentItem.id ? _currentItem : i)
                              .toList();
                          await Storage.saveItems(revertedItems);
                          Get.snackbar('Undone', 'Edit reverted',
                              duration: Duration(seconds: 2),
                              backgroundColor:
                                  AppColors.accent.withOpacity(0.8));
                        },
                        child: Text('Undo',
                            style: TextStyle(color: AppColors.background)),
                      ),
                    );
                  },
                  initialPrice: entry.price, // Pass current price
                  initialLocation: entry.location, // Pass current location
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deletePriceEntry(PriceEntry entry) async {
    if (_currentItem.priceHistory.length <= 1) {
      Get.snackbar('Error', 'Cannot delete the last price entry',
          colorText: Colors.white,
          backgroundColor: Colors.red.withOpacity(0.8));
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
    final items = await Storage.loadItems();
    final updatedItems =
        items.map((i) => i.id == _currentItem.id ? _currentItem : i).toList();
    await Storage.saveItems(updatedItems);
    Get.snackbar(
      'Deleted',
      'Price entry removed',
      backgroundColor: AppColors.accent.withOpacity(0.8),
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
      mainButton: TextButton(
        onPressed: () async {
          setState(() => _currentItem = previousItem);
          final items = await Storage.loadItems();
          final revertedItems = items
              .map((i) => i.id == _currentItem.id ? _currentItem : i)
              .toList();
          await Storage.saveItems(revertedItems);
          Get.snackbar('Undone', 'Deletion reverted',
              duration: Duration(seconds: 2),
              backgroundColor: AppColors.accent.withOpacity(0.8));
        },
        child: Text('Undo', style: TextStyle(color: AppColors.background)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            title: Text(
              _currentItem.name,
              style: TextStyle(color: AppColors.background),
            ),
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: AppColors.background),
              onPressed: Get.back,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.file(
                File(_currentItem.photoPath),
                fit: BoxFit.cover,
              ),
            ),
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              _currentItem.tag,
                              style: csTextTheme().bodyMedium?.copyWith(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Price Trend',
                              style: Theme.of(context).textTheme.titleLarge),
                          SizedBox(height: 8),
                          Text(
                            _calculateTrend(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: _currentItem.priceHistory.length < 2
                                      ? AppColors.textSecondary
                                      : _currentItem.priceHistory.last.price >
                                              _currentItem
                                                  .priceHistory.first.price
                                          ? AppColors.accent
                                          : Colors.redAccent,
                                ),
                          ),
                          SizedBox(height: 16),
                          Text('Price History',
                              style: Theme.of(context).textTheme.titleLarge),
                          SizedBox(height: 8),
                          ..._currentItem.priceHistory.map(
                            (entry) => Dismissible(
                              key: Key(
                                  '${entry.price}-${entry.date.millisecondsSinceEpoch}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (direction) =>
                                  _deletePriceEntry(entry),
                              child: GestureDetector(
                                onTap: () => _editPriceEntry(entry),
                                child: ListTile(
                                  title: Text(
                                    _formatPrice(
                                        entry.price), // Use formatted price
                                    style: csTextTheme().bodyLarge?.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '${entry.location} - ${getRelativeTime(entry.date)}',
                                    style: csTextTheme()
                                        .bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  // trailing: IconButton(
                                  //   icon: Icon(Icons.edit,
                                  //       color: AppColors.textSecondary),
                                  //   onPressed: () => _editPriceEntry(entry),
                                  // ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        shape: CircleBorder(),
        onPressed: _addNewEntry,
        backgroundColor: AppColors.accent,
        child: Icon(Icons.add),
      ),
    );
  }
}
