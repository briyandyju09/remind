class InventoryItem {
  final String id;
  final String name;
  final int quantity;
  final String category;
  final DateTime purchaseDate;
  final int estimatedDaysToRunOut;
  final UsageFrequency usageFrequency;
  final String? notes;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    required this.purchaseDate,
    required this.estimatedDaysToRunOut,
    required this.usageFrequency,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'purchaseDate': purchaseDate.toIso8601String(),
      'estimatedDaysToRunOut': estimatedDaysToRunOut,
      'usageFrequency': usageFrequency.toString(),
      'notes': notes,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      category: map['category'],
      purchaseDate: DateTime.parse(map['purchaseDate']),
      estimatedDaysToRunOut: map['estimatedDaysToRunOut'],
      usageFrequency: UsageFrequency.values.firstWhere(
            (e) => e.toString() == map['usageFrequency'],
      ),
      notes: map['notes'],
    );
  }

  int get daysOwned => DateTime.now().difference(purchaseDate).inDays;

  double get usagePercentage {
    if (estimatedDaysToRunOut == 0) return 100;
    return ((daysOwned / estimatedDaysToRunOut) * 100).clamp(0, 100);
  }

  bool get isRunningLow => usagePercentage > 80;
  bool get isExpiringSoon => daysOwned > estimatedDaysToRunOut;
}

enum UsageFrequency {
  frequent,
  normal,
  rare,
}