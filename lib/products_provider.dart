import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  Future<void> addProduct() async {
    final url =
        Uri.parse('https://your-project-id.firebaseio.com/products.json');

    try {
      await http.post(
        url,
        body: json.encode({
          'title': 'Test Product',
          'description': 'Description here',
        }),
      );

      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }
}
