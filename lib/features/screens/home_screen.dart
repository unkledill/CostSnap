import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/item.dart';
import '../../theme/theme.dart';
import '../../utils/storage.dart';
import '../widgets/item_list.dart';
import 'details_screen.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  final List<Item> items;
  final Function(List<Item>) onItemsChanged;
  final bool showInUSD;
  final Function(bool) onCurrencyChanged;

  const HomeScreen({
    super.key,
    required this.items,
    required this.onItemsChanged,
    required this.showInUSD,
    required this.onCurrencyChanged,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedTag;
  // static const double _exchangeRate = 1600.0;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadFilter();
  }

  Future<void> _loadItems() async {
    final loadedItems = await Storage.loadItems();
    widget.onItemsChanged(loadedItems);
  }

  Future<void> _loadFilter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _selectedTag = prefs.getString('selectedTag'));
  }

  Future<void> _saveFilter(String? tag) async {
    final prefs = await SharedPreferences.getInstance();
    if (tag == null) {
      await prefs.remove('selectedTag');
    } else {
      await prefs.setString('selectedTag', tag);
    }
    setState(() => _selectedTag = tag);
  }

  Future<void> _deleteItem(Item item) async {
    widget.onItemsChanged([...widget.items..remove(item)]);
    await Storage.saveItems(widget.items);
    Get.snackbar('Deleted', '${item.name} removed',
        backgroundColor: AppColors.accent.withOpacity(0.8));
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.25,
        maxChildSize: 0.75,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 8), // Fix to 'bottom' later
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Filter',
                    style: csTextTheme()
                        .titleLarge
                        ?.copyWith(color: AppColors.primary),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      'All',
                      style: TextStyle(
                        fontWeight: _selectedTag == null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      _saveFilter(null);
                      Get.back();
                    },
                  ),
                  ...['Grocery', 'Stationary', 'Consumables', 'Others'].map(
                    (tag) => ListTile(
                      title: Text(
                        tag,
                        style: TextStyle(
                          fontWeight: _selectedTag == tag
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        _saveFilter(tag);
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      isDismissible: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 170, left: 70, right: 70),
      child: Center(
        child: Column(
          children: [
            Image.asset('assets/images/Empty_states_homepage.png', height: 200),
            SizedBox(height: 24),
            Text(
              _selectedTag == null
                  ? 'No items yet!'
                  : 'No $_selectedTag items yet!',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 8),
            Text(
              'Snap a product to start tracking prices.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _selectedTag == null
        ? widget.items
        : widget.items.where((item) => item.tag == _selectedTag).toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('${_getGreeting()} 😊',
            style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: Icon(widget.showInUSD
                ? CupertinoIcons.money_dollar_circle_fill
                : CupertinoIcons.money_dollar_circle),
            onPressed: () => widget.onCurrencyChanged(!widget.showInUSD),
            tooltip: widget.showInUSD ? 'Switch to Naira' : 'Switch to USD',
          ),
          IconButton(
            icon: Icon(Icons.filter_list_rounded),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: filteredItems.isEmpty
                ? _buildEmptyState()
                : ItemList(
                    items: filteredItems,
                    onItemTap: (item) async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                              item: item, showInUSD: widget.showInUSD),
                        ),
                      );
                      await _loadItems();
                    },
                    onDelete: _deleteItem,
                    showInUSD: widget.showInUSD,
                  ),
          ),
        ],
      ),
    );
  }
}
