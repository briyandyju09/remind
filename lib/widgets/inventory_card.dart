import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../services/mock_suggestions_service.dart';

class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;

  const InventoryCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(item.category),
                              labelStyle: Theme.of(context).textTheme.labelSmall,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Qty: ${item.quantity}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (item.isRunningLow)
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: item.usagePercentage / 100,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                color: _getProgressColor(context),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Purchased ${item.daysOwned} days ago',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    MockSuggestionsService.getUsageFrequencyText(item.usageFrequency),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primaryContainer;
  }

  IconData _getCategoryIcon() {
    switch (item.category.toLowerCase()) {
      case 'dairy':
        return Icons.egg_outlined;
      case 'personal care':
        return Icons.self_improvement;
      case 'pantry':
        return Icons.kitchen;
      case 'household':
        return Icons.home;
      case 'beverages':
        return Icons.local_cafe;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getProgressColor(BuildContext context) {
    if (item.usagePercentage > 80) {
      return Theme.of(context).colorScheme.error;
    } else if (item.usagePercentage > 50) {
      return Colors.orange;
    }
    return Theme.of(context).colorScheme.primary;
  }
}