import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/inventory_service.dart';
import '../models/inventory_item.dart';
import '../widgets/inventory_card.dart';
import '../widgets/filter_chip_row.dart';
import 'scanner_screen.dart';
import 'grocery_checker_screen.dart';
import 'settings_screen.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          const FilterChipRow(),
          _buildSortDropdown(context),
          Expanded(
            child: Consumer<InventoryService>(
              builder: (context, service, _) {
                if (service.items.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildInventoryList(context, service.items);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'scan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              );
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan Receipt'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'check',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GroceryCheckerScreen()),
              );
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('Check List'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchBar(
        hintText: 'Search items...',
        leading: const Icon(Icons.search),
        onChanged: (value) {
          context.read<InventoryService>().setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildSortDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text('Sort by: '),
          const SizedBox(width: 8),
          Consumer<InventoryService>(
            builder: (context, service, _) {
              return DropdownButton<String>(
                value: service.sortBy,
                items: ['Recent', 'Name', 'Category', 'Running Low']
                    .map((sort) => DropdownMenuItem(
                  value: sort,
                  child: Text(sort),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    service.setSortBy(value);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList(BuildContext context, List<InventoryItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return InventoryCard(
          item: items[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailScreen(item: items[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No items in inventory',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Scan a receipt to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}