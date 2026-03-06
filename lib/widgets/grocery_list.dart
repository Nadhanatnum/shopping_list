import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/categories.dart';
import '../models/grocery_item.dart';
import 'new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    // 🚨 1. แก้ไขลิงก์ Firebase ให้สมบูรณ์ (ดึงมาจากรูปที่คุณแคปมาให้)
    final url = Uri.parse(
        'https://shopping-list-da88b-default-rtdb.firebaseio.com/shopping-list.json');

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
        return;
      }
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            // 🚨 2. แก้บั๊ก Error แดง (แปลง String ให้เป็น int) ตรงนี้
            quantity: int.parse(item.value['quantity'].toString()),
            category: category,
          ),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
  }

  void _addItem() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const NewItem()),
    );
    _loadItems();
  }

  IconData _getSmartIcon(String itemName) {
    final lower = itemName.toLowerCase();
    if (lower.contains('milk')) return Icons.local_drink;
    if (lower.contains('apple') || lower.contains('banana')) return Icons.apple;
    if (lower.contains('beef') ||
        lower.contains('pork') ||
        lower.contains('meat')) return Icons.set_meal;
    if (lower.contains('bread')) return Icons.bakery_dining;
    if (lower.contains('cheese')) return Icons.water_drop;
    return Icons.shopping_bag;
  }

  @override
  Widget build(BuildContext context) {
    Widget content =
        const Center(child: CircularProgressIndicator(color: Colors.white));

    if (_error != null) {
      content = Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)));
    } else if (!_isLoading && _groceryItems.isEmpty) {
      content = const Center(
        child: Text('No items added yet.',
            style: TextStyle(color: Colors.white70)),
      );
    } else if (!_isLoading) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          title: Text(
            _groceryItems[index].name,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _groceryItems[index].category.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getSmartIcon(_groceryItems[index].name),
              color: _groceryItems[index].category.color,
            ),
          ),
          trailing: Text(
            '${_groceryItems[index].quantity}x',
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A24),
      appBar: AppBar(
        title: const Text(
          'Your Groceries',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0),
        ),
        backgroundColor: const Color(0xFF14141D),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: content,
    );
  }
}
