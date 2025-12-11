class MockOCRService {
  static Future<List<String>> scanReceipt() async {
    await Future.delayed(const Duration(seconds: 2));

    return [
      'Bread',
      'Eggs',
      'Tomatoes',
      'Shampoo',
      'Orange Juice',
      'Chicken Breast',
    ];
  }
}