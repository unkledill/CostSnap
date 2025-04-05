import 'dart:io';
import 'package:cost_snap/models/item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Storage {
  static Future<String> savePhoto(File photo) async {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await photo.copy(path);
    return path;
  }

  static Future<List<Item>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString('items');
    if (itemsJson == null) return [];
    final List<dynamic> itemsList = jsonDecode(itemsJson);
    return itemsList.map((e) => Item.fromMap(e)).toList();
  }

  static Future<void> saveItems(List<Item> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String itemsJson = jsonEncode(items.map((e) => e.toMap()).toList());
    await prefs.setString('items', itemsJson);
  }

  static Future<void> clearItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('items');
  }
}
