import 'dart:io';
import 'package:cost_snap/theme/theme.dart';
// import 'package:cost_snap/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/item.dart';

class ItemList extends StatelessWidget {
  final List<Item> items;
  final Function(Item)? onItemTap;
  final Function(Item)? onDelete;
  final bool showInUSD;
  static const double _exchangeRate = 1539.42; // 1 USD = 1539.42 NGN

  const ItemList({
    super.key,
    required this.items,
    this.onItemTap,
    this.onDelete,
    required this.showInUSD,
  });

  String _formatPrice(Item item) {
    final latestPrice = item.priceHistory.last.price;
    final NumberFormat formatter = NumberFormat.decimalPattern('en_US');
    if (item.priceHistory.length > 1) {
      return 'Multiple prices';
    }
    if (showInUSD) {
      final usdPrice = latestPrice / _exchangeRate;
      return '\$${formatter.format(usdPrice)}'; // e.g., "$5,194" instead of "$5194.05"
    }
    return 'N${formatter.format(latestPrice)}'; // e.g., "₦300,000" instead of "₦300000.00"
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final latest = item.priceHistory.last;
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.red,
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            if (onDelete != null) onDelete!(item);
          },
          child: GestureDetector(
            onTap: onItemTap != null ? () => onItemTap!(item) : null,
            child: Card(
              shadowColor: const Color.fromARGB(20, 33, 33, 33),
              elevation: 10,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(item.photoPath),
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      left: 20,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          item.tag,
                          style: TextStyle(
                              color: AppColors.background,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ]),
                  ListTile(
                    title: Text(
                      item.name,
                      style: csTextTheme().displayMedium,
                    ),
                    subtitle: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge,
                        children: [
                          TextSpan(
                            text: '${latest.location} - ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: _formatPrice(item),
                            style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold),
                          ),
                          if (item.priceHistory.length == 1)
                            TextSpan(text: '  '),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


  // ${getRelativeTime(latest.date)}