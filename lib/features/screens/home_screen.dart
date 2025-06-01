import 'package:cost_snap/models/item.dart';
import 'package:cost_snap/theme/theme.dart';
import 'package:cost_snap/utils/const.dart';
import 'package:cost_snap/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/item_list.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Item> items;
  final Function(List<Item>) onItemsChanged;
  final String currency;
  final Function(String) onCurrencyChanged;

  const HomeScreen({
    super.key,
    required this.items,
    required this.onItemsChanged,
    required this.currency,
    required this.onCurrencyChanged,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _loadFilter();
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
        initialChildSize: 0.5,
        minChildSize: 0.25,
        maxChildSize: 0.75,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(
                        bottom: AppConstants.smallSpacing),
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
                  const SizedBox(height: AppConstants.mediumSpacing),
                  ListTile(
                    title: Text(
                      'All',
                      style: TextStyle(
                        fontWeight: _selectedTag == null
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
                          color: Theme.of(context).textTheme.bodyLarge?.color,
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
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_rounded,
              size: 100,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            Text(
              _selectedTag == null
                  ? 'No items yet!'
                  : 'No $_selectedTag items yet!',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppConstants.smallSpacing),
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
        title: Text('${_getGreeting()} 😊'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: filteredItems.isEmpty
          ? _buildEmptyState()
          : ItemList(
              items: filteredItems,
              onItemTap: (item) async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailsScreen(item: item, currency: widget.currency),
                  ),
                );
                widget.onItemsChanged(await Storage.loadItems());
              },
              onDelete: _deleteItem,
              currency: widget.currency,
            ),
    );
  }
}
