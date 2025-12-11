class GroceryItem {
  final String name;
  final String? category;
  bool isChecked;

  GroceryItem({
    required this.name,
    this.category,
    this.isChecked = false,
  });
}