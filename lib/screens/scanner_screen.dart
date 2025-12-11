import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/mock_ocr_service.dart';
import '../services/inventory_service.dart';
import '../services/database_service.dart';
import '../models/inventory_item.dart';
import '../models/purchase_history.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isScanning = false;
  bool _hasScanned = false;
  List<ScannedItem> _scannedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
      ),
      body: _hasScanned ? _buildScannedItemsList() : _buildCameraView(),
      floatingActionButton: _hasScanned
          ? FloatingActionButton.extended(
        onPressed: _saveItems,
        icon: const Icon(Icons.check),
        label: const Text('Save Items'),
      )
          : null,
    );
  }

  Widget _buildCameraView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              ),
            ),
            child: _isScanning
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Scanning receipt...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 80,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Position receipt in frame',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (!_isScanning)
            FilledButton.icon(
              onPressed: _scanReceipt,
              icon: const Icon(Icons.document_scanner),
              label: const Text('Scan Receipt'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannedItemsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Found ${_scannedItems.length} items',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _scannedItems.length,
            itemBuilder: (context, index) {
              return _buildScannedItemCard(_scannedItems[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScannedItemCard(ScannedItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: item.name)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: item.name.length),
                      ),
                    onChanged: (value) {
                      setState(() {
                        _scannedItems[index].name = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() {
                      _scannedItems.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: item.category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Dairy', 'Personal Care', 'Pantry', 'Household', 'Beverages', 'Other']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _scannedItems[index].category = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: item.quantity.toString())
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: item.quantity.toString().length),
                      ),
                    onChanged: (value) {
                      setState(() {
                        _scannedItems[index].quantity = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanReceipt() async {
    setState(() {
      _isScanning = true;
    });

    final items = await MockOCRService.scanReceipt();

    setState(() {
      _isScanning = false;
      _hasScanned = true;
      _scannedItems = items.map((name) {
        return ScannedItem(
          name: name,
          category: _guessCategory(name),
          quantity: 1,
        );
      }).toList();
    });
  }

  String _guessCategory(String itemName) {
    final lower = itemName.toLowerCase();
    if (lower.contains('milk') || lower.contains('egg') || lower.contains('cheese')) {
      return 'Dairy';
    } else if (lower.contains('shampoo') || lower.contains('soap') || lower.contains('toothpaste')) {
      return 'Personal Care';
    } else if (lower.contains('bread') || lower.contains('pasta') || lower.contains('rice')) {
      return 'Pantry';
    } else if (lower.contains('juice') || lower.contains('coffee') || lower.contains('tea')) {
      return 'Beverages';
    }
    return 'Other';
  }

  Future<void> _saveItems() async {
    final uuid = const Uuid();
    final now = DateTime.now();

    for (var scannedItem in _scannedItems) {
      // Add to inventory
      final inventoryItem = InventoryItem(
        id: uuid.v4(),
        name: scannedItem.name,
        quantity: scannedItem.quantity,
        category: scannedItem.category,
        purchaseDate: now,
        estimatedDaysToRunOut: _estimateDaysToRunOut(scannedItem.category),
        usageFrequency: UsageFrequency.normal,
      );

      await context.read<InventoryService>().addItem(inventoryItem);

      // Add to purchase history
      final purchase = PurchaseHistory(
        id: uuid.v4(),
        itemName: scannedItem.name,
        category: scannedItem.category,
        purchaseDate: now,
        quantity: scannedItem.quantity,
      );

      await DatabaseService.addPurchaseHistory(purchase);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${_scannedItems.length} items to inventory'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  int _estimateDaysToRunOut(String category) {
    switch (category) {
      case 'Dairy':
        return 7;
      case 'Personal Care':
        return 60;
      case 'Pantry':
        return 90;
      case 'Household':
        return 30;
      case 'Beverages':
        return 14;
      default:
        return 30;
    }
  }
}

class ScannedItem {
  String name;
  String category;
  int quantity;

  ScannedItem({
    required this.name,
    required this.category,
    required this.quantity,
  });
}