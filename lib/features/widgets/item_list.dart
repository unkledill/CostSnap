import 'dart:io';
import 'package:cost_snap/models/item.dart';
import 'package:cost_snap/theme/theme.dart';
import 'package:cost_snap/utils/const.dart';
import 'package:cost_snap/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemList extends StatelessWidget {
  final List<Item> items;
  final Function(Item)? onItemTap;
  final Function(Item)? onDelete;
  final String currency;

  const ItemList({
    super.key,
    required this.items,
    this.onItemTap,
    this.onDelete,
    required this.currency,
  });

  String _formatPrice(Item item) {
    final latestPrice = item.priceHistory.last.price;
    final formatter = NumberFormat.decimalPattern('en_US');
    final rate = AppConstants.exchangeRates[currency] ?? 1.0;
    final convertedPrice = latestPrice * rate;
    return '${currency == 'USD' ? '\$' : currency == 'EUR' ? '€' : currency == 'GBP' ? '£' : 'N'}${formatter.format(convertedPrice)}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: AppConstants.mediumSpacing),
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
            padding: const EdgeInsets.only(right: AppConstants.mediumSpacing),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => onDelete?.call(item),
          child: GestureDetector(
            onTap: () => onItemTap?.call(item),
            child: Card(
              color: Theme.of(context).colorScheme.onSurface,
              shadowColor: const Color.fromARGB(20, 33, 33, 33),
              elevation: 8,
              margin: const EdgeInsets.symmetric(
                vertical: AppConstants.smallSpacing,
                horizontal: AppConstants.mediumSpacing,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(item.photoPath),
                          width: double.infinity,
                          height: screenWidth * 0.4,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: AppConstants.mediumSpacing,
                        left: AppConstants.mediumSpacing,
                        child: Container(
                          padding:
                              const EdgeInsets.all(AppConstants.smallSpacing),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.tag,
                            style: csTextTheme().bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text(
                      item.name,
                      style: csTextTheme().titleLarge,
                    ),
                    subtitle: RichText(
                      text: TextSpan(
                        style: csTextTheme().bodyLarge,
                        children: item.priceHistory.length > 1
                            ? [
                                TextSpan(
                                  text: 'Multiple Entry',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${getRelativeTime(latest.date)}',
                                ),
                              ]
                            : [
                                TextSpan(
                                  text: '${latest.location} - ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: _formatPrice(item),
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${getRelativeTime(latest.date)}',
                                ),
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
