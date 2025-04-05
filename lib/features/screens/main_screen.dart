import 'dart:io';
import 'package:cost_snap/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/item.dart';
import 'add_item_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import '../../utils/storage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Item> _items = [];
  bool _showInUSD = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final loadedItems = await Storage.loadItems();
    setState(() => _items = loadedItems);
  }

  void _updateItems(List<Item> items) {
    setState(() => _items = items);
  }

  void _updateCurrency(bool showInUSD) {
    setState(() => _showInUSD = showInUSD);
  }

  Future<void> _addItem() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    Get.to(
      () => AddItemScreen(
        onItemAdded: (name, price, location, photo, tag) async {
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
          setState(() => _items.insert(0, newItem));
          await Storage.saveItems(_items);
        },
        initialPhoto: pickedFile != null ? File(pickedFile.path) : null,
      ),
      transition: Transition.rightToLeft,
      duration: Duration(milliseconds: 350),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        items: _items,
        onItemsChanged: _updateItems,
        showInUSD: _showInUSD,
        onCurrencyChanged: _updateCurrency,
      ),
      SettingsScreen(
        items: _items,
        onItemsChanged: _updateItems,
        onCurrencyChanged: _updateCurrency,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomAppBarTheme.color,
        elevation: 8,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navBar(
              label: 'Home',
              activeIcon: 'assets/images/a.home.png',
              inactiveIcon: 'assets/images/in.home.png',
              index: 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            SizedBox(width: 48),
            _navBar(
              label: 'Settings',
              activeIcon: 'assets/images/a.settings.png',
              inactiveIcon: 'assets/images/in.settings.png',
              index: 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        shape: CircleBorder(),
        elevation: 0,
        onPressed: _addItem,
        child: Icon(CupertinoIcons.camera_fill),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _navBar({
    required String label,
    required String activeIcon,
    required String inactiveIcon,
    required int index,
    Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            height: 20.0,
            width: 20.0,
            _currentIndex == index ? activeIcon : inactiveIcon,
            color: _currentIndex == index
                ? AppColors.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
          Text(
            label,
            style: TextStyle(
              color: _currentIndex == index
                  ? AppColors.primary
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
