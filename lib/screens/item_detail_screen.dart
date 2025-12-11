import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/inventory_item.dart';
import '../services/inventory_service.dart';
import '../services/database_service.dart';
import '../services/mock_suggestions_service.dart';

class ItemDetailScreen extends StatelessWidget {
  final InventoryItem item;

  const ItemDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final purchaseHistory = DatabaseService.getPurchaseHistoryForItem(item.name);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteItem(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildUsageSection(context),
            _buildDetailsSection(context),
            if (purchaseHistory.isNotEmpty) _buildHistorySection(context, purchaseHistory),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(),
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(item.category),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usage Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: item.usagePercentage / 100,
            minHeight: 12,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            color: _getProgressColor(context),
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 8),
          Text(
            '${item.usagePercentage.toStringAsFixed(0)}% of estimated duration used',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Days Owned',
                  '${item.daysOwned}',
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Quantity',
                  '${item.quantity}',
                  Icons.inventory_2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Est. Days Left',
                  '${item.estimatedDaysToRunOut - item.daysOwned}',
                  Icons.access_time,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Usage',
                  MockSuggestionsService.getUsageFrequencyText(item.usageFrequency),
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            'Purchase Date',
            DateFormat('MMM dd, yyyy').format(item.purchaseDate),
          ),
          _buildDetailRow(
            context,
            'Category',
            item.category,
          ),
          if (item.notes != null && item.notes!.isNotEmpty)
            _buildDetailRow(
              context,
              'Notes',
              item.notes!,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, List<dynamic> history) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...history.map((purchase) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.receipt),
                title: Text(DateFormat('MMM dd, yyyy').format(purchase.purchaseDate)),
                subtitle: Text('Quantity: ${purchase.quantity}'),
                trailing: purchase.price != null
                    ? Text(
                  '\$${purchase.price!.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                )
                    : null,
              ),
            );
          }).toList(),
        ],
      ),
    );
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

  Future<void> _deleteItem(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<InventoryService>().deleteItem(item.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}