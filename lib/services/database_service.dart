import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory_item.dart';
import '../models/purchase_history.dart';

class DatabaseService {
  static const String inventoryBox = 'inventory';
  static const String purchaseHistoryBox = 'purchase_history';
  static const String settingsBox = 'settings';

  static Future<void> initialize() async {
    await Hive.openBox(inventoryBox);
    await Hive.openBox(purchaseHistoryBox);
    await Hive.openBox(settingsBox);

    final settings = Hive.box(settingsBox);
    if (settings.get('first_launch', defaultValue: true)) {
      await loadDemoData();
      await settings.put('first_launch', false);
      await settings.put('onboarding_complete', false);
      await settings.put('nudges_enabled', true);
    }
  }

  static Future<void> loadDemoData() async {
    await clearAllData();

    final now = DateTime.now();
    final uuid = const Uuid();

    final demoItems = [
      InventoryItem(
        id: uuid.v4(),
        name: 'Milk',
        quantity: 1,
        category: 'Dairy',
        purchaseDate: now.subtract(const Duration(days: 3)),
        estimatedDaysToRunOut: 7,
        usageFrequency: UsageFrequency.frequent,
        notes: '1 liter, full fat',
      ),
      InventoryItem(
        id: uuid.v4(),
        name: 'Toothpaste',
        quantity: 1,
        category: 'Personal Care',
        purchaseDate: now.subtract(const Duration(days: 25)),
        estimatedDaysToRunOut: 60,
        usageFrequency: UsageFrequency.frequent,
      ),
      InventoryItem(
        id: uuid.v4(),
        name: 'Pasta',
        quantity: 2,
        category: 'Pantry',
        purchaseDate: now.subtract(const Duration(days: 60)),
        estimatedDaysToRunOut: 90,
        usageFrequency: UsageFrequency.rare,
        notes: 'Rarely cook pasta',
      ),
      InventoryItem(
        id: uuid.v4(),
        name: 'Dish Soap',
        quantity: 1,
        category: 'Household',
        purchaseDate: now.subtract(const Duration(days: 10)),
        estimatedDaysToRunOut: 30,
        usageFrequency: UsageFrequency.normal,
      ),
      InventoryItem(
        id: uuid.v4(),
        name: 'Eggs',
        quantity: 12,
        category: 'Dairy',
        purchaseDate: now.subtract(const Duration(days: 5)),
        estimatedDaysToRunOut: 14,
        usageFrequency: UsageFrequency.frequent,
        notes: 'Dozen eggs',
      ),
      InventoryItem(
        id: uuid.v4(),
        name: 'Shampoo',
        quantity: 2,
        category: 'Personal Care',
        purchaseDate: now.subtract(const Duration(days: 15)),
        estimatedDaysToRunOut: 45,
        usageFrequency: UsageFrequency.normal,
        notes: '2 unopened bottles',
      ),
      InventoryItem(
        id: uuid.v4(),
        name: 'Rice',
        quantity: 1,
        category: 'Pantry',
        purchaseDate: now.subtract(const Duration(days: 40)),
        estimatedDaysToRunOut: 120,
        usageFrequency: UsageFrequency.normal,
        notes: '5kg bag, half used',
      ),
      InventoryItem(
        id: uuid.v4(),
        name: 'Coffee',
        quantity: 1,
        category: 'Beverages',
        purchaseDate: now.subtract(const Duration(days: 8)),
        estimatedDaysToRunOut: 20,
        usageFrequency: UsageFrequency.frequent,
      ),
      InventoryItem(
        id: uuid.v4(),
        name: 'Olive Oil',
        quantity: 1,
        category: 'Pantry',
        purchaseDate: now.subtract(const Duration(days: 90)),
        estimatedDaysToRunOut: 180,
        usageFrequency: UsageFrequency.normal,
      ),
      InventoryItem(
        id: uuid.v4(),
        name: 'Paper Towels',
        quantity: 3,
        category: 'Household',
        purchaseDate: now.subtract(const Duration(days: 20)),
        estimatedDaysToRunOut: 45,
        usageFrequency: UsageFrequency.normal,
        notes: '3 unopened rolls',
      ),
    ];

    final inventoryBoxInstance = Hive.box(inventoryBox);
    for (var item in demoItems) {
      await inventoryBoxInstance.put(item.id, item.toMap());
    }

    final demoPurchases = [
      PurchaseHistory(
        id: uuid.v4(),
        itemName: 'Milk',
        category: 'Dairy',
        purchaseDate: now.subtract(const Duration(days: 3)),
        quantity: 1,
        price: 4.99,
      ),
      PurchaseHistory(
        id: uuid.v4(),
        itemName: 'Milk',
        category: 'Dairy',
        purchaseDate: now.subtract(const Duration(days: 10)),
        quantity: 1,
        price: 4.99,
      ),
      PurchaseHistory(
        id: uuid.v4(),
        itemName: 'Eggs',
        category: 'Dairy',
        purchaseDate: now.subtract(const Duration(days: 5)),
        quantity: 12,
        price: 6.49,
      ),
      PurchaseHistory(
        id: uuid.v4(),
        itemName: 'Toothpaste',
        category: 'Personal Care',
        purchaseDate: now.subtract(const Duration(days: 25)),
        quantity: 1,
        price: 5.99,
      ),
      PurchaseHistory(
        id: uuid.v4(),
        itemName: 'Pasta',
        category: 'Pantry',
        purchaseDate: now.subtract(const Duration(days: 60)),
        quantity: 2,
        price: 3.98,
      ),
    ];

    final purchaseBoxInstance = Hive.box(purchaseHistoryBox);
    for (var purchase in demoPurchases) {
      await purchaseBoxInstance.put(purchase.id, purchase.toMap());
    }
  }

  static Future<void> clearAllData() async {
    await Hive.box(inventoryBox).clear();
    await Hive.box(purchaseHistoryBox).clear();
  }

  static Future<void> resetToDemo() async {
    await loadDemoData();
  }

  static Future<void> addInventoryItem(InventoryItem item) async {
    final box = Hive.box(inventoryBox);
    await box.put(item.id, item.toMap());
  }

  static Future<void> updateInventoryItem(InventoryItem item) async {
    final box = Hive.box(inventoryBox);
    await box.put(item.id, item.toMap());
  }

  static Future<void> deleteInventoryItem(String id) async {
    final box = Hive.box(inventoryBox);
    await box.delete(id);
  }

  static List<InventoryItem> getAllInventoryItems() {
    final box = Hive.box(inventoryBox);
    return box.values
        .map((e) => InventoryItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> addPurchaseHistory(PurchaseHistory purchase) async {
    final box = Hive.box(purchaseHistoryBox);
    await box.put(purchase.id, purchase.toMap());
  }

  static List<PurchaseHistory> getAllPurchaseHistory() {
    final box = Hive.box(purchaseHistoryBox);
    return box.values
        .map((e) => PurchaseHistory.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static List<PurchaseHistory> getPurchaseHistoryForItem(String itemName) {
    final allHistory = getAllPurchaseHistory();
    return allHistory
        .where((p) => p.itemName.toLowerCase() == itemName.toLowerCase())
        .toList()
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
  }

  static Future<void> setSetting(String key, dynamic value) async {
    final box = Hive.box(settingsBox);
    await box.put(key, value);
  }

  static T getSetting<T>(String key, T defaultValue) {
    final box = Hive.box(settingsBox);
    return box.get(key, defaultValue: defaultValue) as T;
  }
}