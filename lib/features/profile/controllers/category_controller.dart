import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  // Return only categories that have at least 1 product
  List<CategoryModel> get categoriesWithProducts {
    return _categories.where((cat) {
      return cat.subCategories.any((sub) => sub.products.isNotEmpty);
    }).toList();
  }

  final String baseUrl =
      "https://online-store-api-ashy.vercel.app/api/categories";

  Future<void> fetchCategories() async {
    _isLoading = true;

    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'];
        _categories = data.map((e) => CategoryModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load categories: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
