import 'package:flutter/material.dart';

import 'controllers/category_controller.dart';
import 'models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryController _controller = CategoryController();

  bool isLoading = false;
  List<Category> categories = [];
  List<Category> _validCategories = []; // Cached filtered list
  String? errorMessage; // New: For UI-friendly error display

  // Getter for filtered categories—computed once in fetch
  List<Category> get validCategories => _validCategories;

  Future<void> fetchCategories() async {
    isLoading = true;
    errorMessage = null; // Reset on each call
    notifyListeners(); // Safe here, as we'll call this post-build

    try {
      categories = await _controller.fetchCategories();
      // Filter once here: Only categories with at least one non-empty subCategory.products
      _validCategories = categories.where((category) {
        final subCategory = category.subCategories.firstWhere(
              (sub) => sub.products.isNotEmpty,
          orElse: () => SubCategory(id: '', name: '', products: []),
        );
        return subCategory.products.isNotEmpty;
      }).toList();
    } catch (e) {
      errorMessage = "Failed to fetch categories: $e"; // Expose error to UI
      print(errorMessage); // Keep for debugging
      _validCategories = []; // Clear on error
    }

    isLoading = false;
    notifyListeners(); // Triggers UI rebuild safely
  }
}