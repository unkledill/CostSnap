import 'package:cost_snap/models/item.dart';
import 'package:cost_snap/theme/theme.dart';
import 'package:cost_snap/utils/const.dart';
import 'package:cost_snap/utils/storage.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../service/exchange_rate_service.dart';

class SettingsScreen extends StatefulWidget {
  final List<Item> items;
  final Function(List<Item>) onItemsChanged;
  final Function(String) onCurrencyChanged;

  const SettingsScreen({
    super.key,
    required this.items,
    required this.onItemsChanged,
    required this.onCurrencyChanged,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ExchangeRateService _exchangeRateService = ExchangeRateService();

  @override
  void initState() {
    super.initState();
    _loadCurrency();
    _fetchExchangeRates();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final currency = prefs.getString('currency') ?? 'NGN';
    setState(() {
      AppConstants.selectedCurrency = currency;
    });
    widget.onCurrencyChanged(currency);
  }

  Future<void> _saveCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    setState(() {
      AppConstants.selectedCurrency = currency;
    });
    widget.onCurrencyChanged(currency);
    Get.snackbar('Currency Updated', 'Now using $currency',
        backgroundColor: AppColors.accent.withOpacity(0.8));
  }

  Future<void> _fetchExchangeRates() async {
    try {
      final rates = await _exchangeRateService.fetchExchangeRates();
      setState(() {
        AppConstants.exchangeRates = rates;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch exchange rates',
          backgroundColor: Colors.red.withOpacity(0.8));
    }
  }

  Future<void> _exportData() async {
    try {
      final items = await Storage.loadItems();
      if (items.isEmpty) {
        Get.snackbar('No Data', 'No items to export',
            backgroundColor: Colors.red.withOpacity(0.8));
        return;
      }
      final csvData = <List<dynamic>>[
        ['ID', 'Item Name', 'Price', 'Location', 'Date'],
        ...items
            .expand((item) => item.priceHistory.map((entry) => [
                  item.id,
                  item.name,
                  entry.price,
                  entry.location,
                  entry.date.toIso8601String(),
                ]))
            .toList(),
      ];
      final csvString = const ListToCsvConverter().convert(csvData);
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/costsnap_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      await File(path).writeAsString(csvString);
      await Share.shareXFiles([XFile(path)], text: 'CostSnap Data Export');
      Get.snackbar('Success', 'Data exported successfully',
          backgroundColor: AppColors.accent.withOpacity(0.8));
    } catch (e) {
      Get.snackbar('Error', 'Failed to export data',
          backgroundColor: Colors.red.withOpacity(0.8));
    }
  }

  Future<void> _clearData() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear Data?'),
        content: const Text('This will delete all items. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm ?? false) {
      await Storage.clearItems();
      widget.onItemsChanged([]);
      Get.snackbar('Cleared', 'All data deleted',
          backgroundColor: AppColors.accent.withOpacity(0.8));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        children: [
          ListTile(
            title: Text('Default Currency', style: csTextTheme().bodyLarge),
            trailing: DropdownButton<String>(
              value: AppConstants.selectedCurrency,
              items: ['NGN', 'USD', 'EUR', 'GBP']
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: csTextTheme().bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) => _saveCurrency(value!),
              style: csTextTheme().bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              borderRadius: BorderRadius.circular(8),
              elevation: 8,
              underline: Container(
                height: 1,
                color: Colors.transparent,
              ),
            ),
          ),
          ListTile(
            title: Text('Export Data', style: csTextTheme().bodyLarge),
            subtitle: Text(
              'Export your data as CSV',
              style: csTextTheme()
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            trailing: const Icon(CupertinoIcons.share),
            onTap: _exportData,
          ),
          ListTile(
            title: Text('Clear All Data', style: csTextTheme().bodyLarge),
            subtitle: Text(
              'This will delete all items',
              style: csTextTheme()
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            trailing: const Icon(CupertinoIcons.delete, color: Colors.red),
            onTap: _clearData,
          ),
        ],
      ),
    );
  }
}
