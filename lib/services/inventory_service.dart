import 'package:flutter/foundation.dart';
import '../models/inventory_item.dart';
import 'database_service.dart';

class InventoryService extends ChangeNotifier {
  List<InventoryItem> _items = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Recent';

  List<InventoryItem> get items {
    var filtered = _items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    switch (_sortBy) {
      case 'Name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Category':
        filtered.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'Recent':
        filtered.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        break;
      case 'Running Low':
        filtered.sort((a, b) => b.usagePercentage.compareTo(a.usagePercentage));
        break;
    }

    return filtered;
  }

  List<String> get categories {
    final cats = _items.map((e) => e.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;

  InventoryService() {
    loadItems();
  }

  Future<void> loadItems() async {
    _items = DatabaseService.getAllInventoryItems();
    notifyListeners();
  }

  Future<void> addItem(InventoryItem item) async {
    await DatabaseService.addInventoryItem(item);
    await loadItems();
  }

  Future<void> updateItem(InventoryItem item) async {
    await DatabaseService.updateInventoryItem(item);
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await DatabaseService.deleteInventoryItem(id);
    await loadItems();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  Future<void> resetToDemo() async {
    await DatabaseService.resetToDemo();
    await loadItems();
  }
}