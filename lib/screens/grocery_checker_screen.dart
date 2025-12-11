import 'package:flutter/material.dart';
import '../models/grocery_item.dart';
import '../models/suggestion.dart';
import '../services/mock_suggestions_service.dart';

class GroceryCheckerScreen extends StatefulWidget {
  const GroceryCheckerScreen({Key? key}) : super(key: key);

  @override
  State<GroceryCheckerScreen> createState() => _GroceryCheckerScreenState();
}

class _GroceryCheckerScreenState extends State<GroceryCheckerScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<GroceryItem> _items = [];
  List<Suggestion> _suggestions = [];
  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Grocery List'),
      ),
      body: Column(
        children: [
          _buildInputSection(),
          if (_items.isNotEmpty) ...[
            _buildItemsList(),
            const Divider(),
            if (_suggestions.isNotEmpty) _buildSuggestions(),
          ],
        ],
      ),
      floatingActionButton: _items.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _analyzeList,
        icon: _isAnalyzing
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.psychology),
        label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze List'),
      )
          : null,
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add items to your grocery list',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter item name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.add_shopping_cart),
                  ),
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Checkbox(
                value: item.isChecked,
                onChanged: (value) {
                  setState(() {
                    item.isChecked = value ?? false;
                  });
                },
              ),
              title: Text(
                item.name,
                style: TextStyle(
                  decoration: item.isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() {
                    _items.removeAt(index);
                    _suggestions.clear();
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuggestions() {
    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Smart Suggestions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return _buildSuggestionCard(_suggestions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(Suggestion suggestion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: suggestion.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                suggestion.icon,
                color: suggestion.color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.itemName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suggestion.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _items.add(GroceryItem(name: _controller.text.trim()));
      _controller.clear();
      _suggestions.clear();
    });
  }

  Future<void> _analyzeList() async {
    setState(() {
      _isAnalyzing = true;
    });

    final suggestions = await MockSuggestionsService.analyzeGroceryList(_items);

    setState(() {
      _suggestions = suggestions;
      _isAnalyzing = false;
    });

    if (_suggestions.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All items look good! No suggestions at this time.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}