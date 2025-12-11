import 'package:flutter/material.dart';

class Suggestion {
  final String itemName;
  final SuggestionType type;
  final String message;
  final IconData icon;
  final Color color;

  Suggestion({
    required this.itemName,
    required this.type,
    required this.message,
    required this.icon,
    required this.color,
  });
}

enum SuggestionType {
  alreadyOwned,
  recentPurchase,
  rarelyUsed,
  multipleUnopened,
  runningLow,
}