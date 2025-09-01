import 'package:flutter/material.dart';

import 'controllers/category_controller.dart';
import 'models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryController _controller = CategoryController();

  bool isLoading = false;
  List<Category> categories = [];

  Future<void> fetchCategories() async {
    isLoading = true;
    notifyListeners();

    try {
      categories = await _controller.fetchCategories();
    } catch (e) {
      print("Error fetching categories: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
