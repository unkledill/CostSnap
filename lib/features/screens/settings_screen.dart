import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/theme.dart';
import '../../utils/storage.dart';
import '../../models/item.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  final List<Item> items;
  final Function(List<Item>) onItemsChanged;
  final Function(bool) onCurrencyChanged;

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
  ThemeMode? _themeMode;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode') ?? 'system';
    setState(() {
      _themeMode = themeString == 'light'
          ? ThemeMode.light
          : themeString == 'dark'
              ? ThemeMode.dark
              : ThemeMode.system;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_themeMode == null) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          backgroundColor: AppColors.background,
          elevation: 0,
          title:
              Text('Settings', style: TextStyle(color: AppColors.textPrimary)),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Settings', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text('Export Data'),
            trailing: Icon(Icons.file_download),
            onTap: () async {
              final csv = widget.items
                  .map((item) =>
                      '${item.name},${item.priceHistory.last.price},${item.tag}')
                  .join('\n');
              final file = File(
                  '${(await getTemporaryDirectory()).path}/costsnap_export.csv');
              await file.writeAsString('Name,Price,Tag\n$csv');
              Share.shareXFiles([XFile(file.path)], text: 'My CostSnap data');
            },
          ),
          ListTile(
            title: Text('Clear All Data'),
            trailing: Icon(Icons.delete_forever, color: Colors.red),
            onTap: () async {
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: Text('Clear Data?'),
                  content: Text('This will delete all items. Continue?'),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text('Cancel')),
                    TextButton(
                        onPressed: () => Get.back(result: true),
                        child: Text('Delete')),
                  ],
                ),
              );
              if (confirm ?? false) {
                await Storage.clearItems();
                widget.onItemsChanged([]);
              }
            },
          ),
        ],
      ),
    );
  }
}
