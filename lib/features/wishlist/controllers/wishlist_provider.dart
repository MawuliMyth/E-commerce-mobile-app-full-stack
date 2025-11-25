import 'package:flutter/material.dart';

import '../../dashboard/models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Product> _wishlistItems = [];
  final List<Product> _recentlyViewed = [];

  List<Product> get wishlistItems => List.unmodifiable(_wishlistItems);
  List<Product> get recentlyViewed => List.unmodifiable(_recentlyViewed);

  bool isInWishlist(String productId) {
    return _wishlistItems.any((item) => item.id == productId);
  }

  void toggleWishlist(Product product) {
    final index = _wishlistItems.indexWhere((item) => item.id == product.id);

    if (index != -1) {
      _wishlistItems.removeAt(index);
    } else {
      _wishlistItems.add(product);
    }
    notifyListeners();
  }

  void removeFromWishlist(String productId) {
    _wishlistItems.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void addToRecentlyViewed(Product product) {
    // Remove if already exists
    _recentlyViewed.removeWhere((item) => item.id == product.id);

    // Add to beginning
    _recentlyViewed.insert(0, product);

    // Keep only last 10 items
    if (_recentlyViewed.length > 10) {
      _recentlyViewed.removeLast();
    }

    notifyListeners();
  }

  void clearWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }
}
