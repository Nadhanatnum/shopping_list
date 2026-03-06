import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/categories.dart';
import '../models/category.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();

  // สร้างตัวแปรไว้ด้านบนของ State
  String _enteredName = '';
  var _enteredQuantity = 1;
  // สมมติว่าตั้งค่าเริ่มต้นเป็นผัก
  Category _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    // เช็ค validate ข้อมูล
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSending = true;
      });

      // 🚨 แก้ URL เป็นของคุณให้เรียบร้อยแล้ว! 🚨
      final url = Uri.parse(
          'https://shopping-list-da88b-default-rtdb.firebaseio.com/shopping-list.json');

      try {
        // ยิงขึ้น Firebase (Real-time Sync ขาขึ้น)
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title,
          }),
        );

        // ส่งค่ากลับไปหน้าแรกเพื่อให้ ListView อัปเดตทันที (ไม่ส่ง GroceryItem กลับไปแล้ว)
        if (!context.mounted) return;
        Navigator.of(context).pop();
      } catch (error) {
        setState(() {
          _isSending = false;
        });
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A24),
      appBar: AppBar(
        title: const Text(
          'Add a new item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF14141D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(
                  hintText:
                      'พิมพ์ชื่อสินค้า (เช่น Milk, Apple)...', // Minimalist UI ซ่อนเส้นขอบ
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // ขอบมน
                    borderSide: BorderSide.none, // ลบเส้นขอบทิ้ง
                  ),
                  filled: true,
                  fillColor: const Color(0xFF252530), // สีพื้นหลังช่องกรอก
                  prefixIcon: const Icon(Icons.search,
                      color: Colors.white54), // เพิ่มไอคอนเท่ๆ
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
                onChanged: (value) {
                  setState(() {
                    _enteredName = value;
                    // 💡 โค้ดพระเอก: Auto-Category & Smart Icon
                    final lowerVal = value.toLowerCase();
                    if (lowerVal.contains('milk') ||
                        lowerVal.contains('cheese')) {
                      _selectedCategory = categories[Categories
                          .dairy]!; // เปลี่ยนหมวดเป็นนม/ชีส อัตโนมัติ (เปลี่ยนสี/ไอคอนตามหมวด)
                    } else if (lowerVal.contains('apple') ||
                        lowerVal.contains('banana')) {
                      _selectedCategory = categories[Categories.fruit]!;
                    } else if (lowerVal.contains('beef') ||
                        lowerVal.contains('pork')) {
                      _selectedCategory = categories[Categories.meat]!;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF252530),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid, positive number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField(
                      dropdownColor: const Color(0xFF252530),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF252530),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: category.value.color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text('Add Item',
                            style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
