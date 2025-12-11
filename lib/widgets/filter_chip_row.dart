import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/inventory_service.dart';

class FilterChipRow extends StatelessWidget {
  const FilterChipRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryService>(
      builder: (context, service, _) {
        return SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: service.categories.map((category) {
              final isSelected = service.selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    service.setCategory(category);
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}