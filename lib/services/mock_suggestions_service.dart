import 'package:flutter/material.dart';
import '../models/suggestion.dart';
import '../models/grocery_item.dart';
import '../models/inventory_item.dart';
import 'mock_analytics_service.dart';

class MockSuggestionsService {
  static Future<List<Suggestion>> analyzeGroceryList(List<GroceryItem> items) async {
    final suggestions = <Suggestion>[];

    for (var item in items) {
      final analysis = await MockAnalyticsService.analyzeItem(item.name);

      if (analysis['exists'] == true) {
        final inventoryItem = analysis['item'];
        final daysLeft = analysis['estimatedDaysLeft'];

        if (inventoryItem.quantity > 1) {
          suggestions.add(Suggestion(
            itemName: item.name,
            type: SuggestionType.multipleUnopened,
            message: 'You have ${inventoryItem.quantity} unopened ${item.name} at home',
            icon: Icons.inventory_2,
            color: Colors.orange,
          ));
        } else if (daysLeft > 7) {
          suggestions.add(Suggestion(
            itemName: item.name,
            type: SuggestionType.alreadyOwned,
            message: 'You already have ${item.name} at home (${daysLeft} days left)',
            icon: Icons.check_circle,
            color: Colors.green,
          ));
        } else if (inventoryItem.usageFrequency == UsageFrequency.rare) {
          suggestions.add(Suggestion(
            itemName: item.name,
            type: SuggestionType.rarelyUsed,
            message: 'You rarely use ${item.name}',
            icon: Icons.warning_amber,
            color: Colors.amber,
          ));
        }
      } else if (analysis['hasHistory'] == true) {
        final daysSince = analysis['daysSinceLastPurchase'];
        if (daysSince < 14) {
          suggestions.add(Suggestion(
            itemName: item.name,
            type: SuggestionType.recentPurchase,
            message: 'You bought ${item.name} $daysSince days ago',
            icon: Icons.access_time,
            color: Colors.blue,
          ));
        }
      }
    }

    return suggestions;
  }

  static String getUsageFrequencyText(UsageFrequency frequency) {
    switch (frequency) {
      case UsageFrequency.frequent:
        return 'Used frequently';
      case UsageFrequency.normal:
        return 'Used regularly';
      case UsageFrequency.rare:
        return 'Rarely used';
    }
  }
}