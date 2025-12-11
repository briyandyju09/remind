import '../models/inventory_item.dart';
import 'database_service.dart';

class MockAnalyticsService {
  static Future<Map<String, dynamic>> analyzeItem(String itemName) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final inventory = DatabaseService.getAllInventoryItems();
    final existingItem = inventory.firstWhere(
          (item) => item.name.toLowerCase() == itemName.toLowerCase(),
      orElse: () => InventoryItem(
        id: '',
        name: '',
        quantity: 0,
        category: '',
        purchaseDate: DateTime.now(),
        estimatedDaysToRunOut: 0,
        usageFrequency: UsageFrequency.normal,
      ),
    );

    if (existingItem.id.isNotEmpty) {
      return {
        'exists': true,
        'item': existingItem,
        'daysOwned': existingItem.daysOwned,
        'estimatedDaysLeft': existingItem.estimatedDaysToRunOut - existingItem.daysOwned,
      };
    }

    final history = DatabaseService.getPurchaseHistoryForItem(itemName);
    if (history.isNotEmpty) {
      final lastPurchase = history.first;
      final daysSinceLastPurchase = DateTime.now().difference(lastPurchase.purchaseDate).inDays;

      return {
        'exists': false,
        'hasHistory': true,
        'lastPurchaseDate': lastPurchase.purchaseDate,
        'daysSinceLastPurchase': daysSinceLastPurchase,
        'purchaseCount': history.length,
      };
    }

    return {
      'exists': false,
      'hasHistory': false,
    };
  }
}