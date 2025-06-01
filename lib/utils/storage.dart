import 'dart:convert';
import 'dart:io';
import 'package:cost_snap/models/item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  // Note: shared_preferences is suitable for small datasets. For large datasets, consider a database like Hive or SQLite.
  static Future<String> savePhoto(File photo) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final extension = photo.path.split('.').last.toLowerCase();
      final path =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.$extension';
      await photo.copy(path);
      return path;
    } catch (e) {
      throw Exception('Failed to save photo: $e');
    }
  }

  static Future<List<Item>> loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? itemsJson = prefs.getString('items');
      if (itemsJson == null) return [];
      final List<dynamic> itemsList = jsonDecode(itemsJson);
      return itemsList.map((e) => Item.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveItems(List<Item> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String itemsJson = jsonEncode(items.map((e) => e.toMap()).toList());
      await prefs.setString('items', itemsJson);
    } catch (e) {
      throw Exception('Failed to save items: $e');
    }
  }

  static Future<void> clearItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('items');
    } catch (e) {
      throw Exception('Failed to clear items: $e');
    }
  }
}
