class PurchaseHistory {
  final String id;
  final String itemName;
  final String category;
  final DateTime purchaseDate;
  final int quantity;
  final double? price;

  PurchaseHistory({
    required this.id,
    required this.itemName,
    required this.category,
    required this.purchaseDate,
    required this.quantity,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'category': category,
      'purchaseDate': purchaseDate.toIso8601String(),
      'quantity': quantity,
      'price': price,
    };
  }

  factory PurchaseHistory.fromMap(Map<String, dynamic> map) {
    return PurchaseHistory(
      id: map['id'],
      itemName: map['itemName'],
      category: map['category'],
      purchaseDate: DateTime.parse(map['purchaseDate']),
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}