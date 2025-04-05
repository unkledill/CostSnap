import 'package:cost_snap/models/item.dart';
import 'package:cost_snap/theme/theme.dart';
import 'package:cost_snap/utils/storage.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class CostSnapController extends GetxController {
  RxList<Item> items = <Item>[].obs; // Observable list
  RxString? selectedTag; // Declare without initialization

  CostSnapController() {
    selectedTag = ('').obs; // Initialize as RxString? with null
  }

  @override
  void onInit() {
    super.onInit();
    loadItems();
    loadFilter();
  }

  Future<void> loadItems() async {
    final loadedItems = await Storage.loadItems();
    items.assignAll(loadedItems);
  }

  Future<void> loadFilter() async {
    final prefs = Get.find<SharedPreferences>();
    selectedTag!.value = prefs.getString('selectedTag')!;
  }

  Future<void> saveFilter(String? tag) async {
    final prefs = Get.find<SharedPreferences>();
    if (tag == null) {
      await prefs.remove('selectedTag');
    } else {
      await prefs.setString('selectedTag', tag);
    }
    selectedTag!.value = tag!;
  }

  Future<void> addItem(String name, double price, String location, File photo,
      String tag) async {
    final photoPath = await Storage.savePhoto(photo);
    final newItem = Item(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      photoPath: photoPath,
      priceHistory: [
        PriceEntry(price: price, location: location, date: DateTime.now())
      ],
      tag: tag,
    );
    items.add(newItem);
    await Storage.saveItems(items);
  }

  Future<void> deleteItem(Item item) async {
    items.remove(item);
    await Storage.saveItems(items);
    Get.snackbar('Deleted', '${item.name} removed',
        backgroundColor: AppColors.accent.withOpacity(0.8));
  }

  Future<void> updateItem(Item oldItem, double price, String location) async {
    final updatedItem = Item(
      id: oldItem.id,
      name: oldItem.name,
      photoPath: oldItem.photoPath,
      priceHistory: [
        ...oldItem.priceHistory,
        PriceEntry(price: price, location: location, date: DateTime.now()),
      ],
      tag: oldItem.tag,
    );
    final index = items.indexOf(oldItem);
    if (index != -1) {
      items[index] = updatedItem;
      await Storage.saveItems(items);
      Get.snackbar('Updated', 'New price added for ${updatedItem.name}',
          backgroundColor: AppColors.accent.withOpacity(0.8));
    }
  }

  List<Item> get filteredItems =>
      // ignore: unnecessary_null_comparison
      selectedTag!.value == null
          ? items
          : items.where((item) => item.tag == selectedTag!.value).toList();
}
