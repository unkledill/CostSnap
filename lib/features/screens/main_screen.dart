import 'dart:io';
import 'package:cost_snap/features/screens/add_item_screen.dart';
import 'package:cost_snap/features/screens/home_screen.dart';
import 'package:cost_snap/features/screens/settings_screen.dart';
import 'package:cost_snap/models/item.dart';
import 'package:cost_snap/theme/theme.dart';
import 'package:cost_snap/utils/const.dart';
import 'package:cost_snap/utils/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MainScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;

  const MainScreen({super.key, this.onThemeChanged});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Item> _items = [];
  String _currency = 'USD';
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

  void _updateCurrency(String currency) {
    setState(() => _currency = currency);
  }

  Future<void> _addItem() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;
    Get.to(
      () => AddItemScreen(
        onItemAdded: (name, price, location, photo, tag) async {
          final photoPath = await Storage.savePhoto(photo);
          final newItem = Item(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            photoPath: photoPath,
            priceHistory: [
              PriceEntry(
                  price: price, location: location, date: DateTime.now()),
            ],
            tag: tag,
          );
          setState(() => _items.insert(0, newItem));
          await Storage.saveItems(_items);
        },
        initialPhoto: File(pickedFile.path),
      ),
      transition: Transition.rightToLeft,
      duration: AppConstants.animationDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        items: _items,
        onItemsChanged: _updateItems,
        currency: _currency,
        onCurrencyChanged: _updateCurrency,
      ),
      SettingsScreen(
        items: _items,
        onItemsChanged: _updateItems,
        onCurrencyChanged: _updateCurrency,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              label: 'Home',
              activeIcon: 'assets/images/a.home.png',
              inactiveIcon: 'assets/images/in.home.png',
              index: 0,
            ),
            const SizedBox(width: 48),
            _buildNavItem(
              label: 'Settings',
              activeIcon: 'assets/images/a.settings.png',
              inactiveIcon: 'assets/images/in.settings.png',
              index: 1,
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

  Widget _buildNavItem({
    required String label,
    required String activeIcon,
    required String inactiveIcon,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            isActive ? activeIcon : inactiveIcon,
            height: MediaQuery.of(context).size.width * 0.05,
            width: MediaQuery.of(context).size.width * 0.05,
            color: isActive
                ? AppColors.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? AppColors.primary
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
