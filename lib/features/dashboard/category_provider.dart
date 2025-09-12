import 'package:flutter/material.dart';
import 'controllers/category_controller.dart';
import 'models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryController _controller = CategoryController();

  bool _isLoading = false;
  List<Category> _categories = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Category> get categories => _categories;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
      _errorMessage = null; // Reset error message
      notifyListeners(); // Notify that loading has started

      _categories = await _controller.fetchCategories();

      _isLoading = false;
      notifyListeners(); // Notify that data is ready
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load categories: $e';
      notifyListeners(); // Notify on error
      print('Error fetching categories: $e');
    }
  }
}