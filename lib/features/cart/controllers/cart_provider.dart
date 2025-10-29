import 'package:flutter/foundation.dart';

import '../models/cart_model.dart';
import 'cart_service_controller.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  bool _isAddingToCart = false;
  String? _errorMessage;
  int _cartItemCount = 0;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  bool get isAddingToCart => _isAddingToCart;
  String? get errorMessage => _errorMessage;
  int get cartItemCount => _cartItemCount;

  // ✅ Calculate total cart price
  double get totalPrice {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  // ✅ Fetch Cart Items
  Future<void> fetchCart({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    final result = await _cartService.getCart();
    _isLoading = false;

    if (result['success']) {
      try {
        final data = result['data'];
        List<dynamic> itemsData = [];

        // 🔍 Try all possible response shapes
        if (data is List) {
          itemsData = data;
        } else if (data?['items'] != null) {
          itemsData = data['items'];
        } else if (data?['data']?['items'] != null) {
          itemsData = data['data']['items'];
        }

        // ✅ Parse items safely
        _cartItems = itemsData
            .map((item) {
              try {
                return CartItem.fromJson(item);
              } catch (e) {
                if (kDebugMode) print('⚠️ Skipped invalid cart item: $e');
                return CartItem.empty(); // fallback empty item
              }
            })
            .where((item) => item.id.isNotEmpty)
            .toList();

        _cartItemCount = _cartItems.length;
        _errorMessage = null;

        if (kDebugMode) {
          print('✅ Cart fetched successfully: $_cartItemCount items');
          if (_cartItems.isNotEmpty) {
            print('🖼 First item image: ${_cartItems.first.image}');
            print('🖼 First item images list: ${_cartItems.first.images}');
          }
        }
      } catch (e) {
        _errorMessage = 'Error parsing cart data';
        _cartItems = [];
        _cartItemCount = 0;
        if (kDebugMode) print('❌ Error parsing cart items: $e');
      }
    } else {
      _errorMessage = result['message'] ?? 'Failed to load cart';
      _cartItems = [];
      _cartItemCount = 0;
    }

    notifyListeners();
  }

  // ✅ Add Item to Cart
  Future<bool> addToCart({required String productId, int quantity = 1}) async {
    _isAddingToCart = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _cartService.addToCart(
      productId: productId,
      quantity: quantity,
    );

    _isAddingToCart = false;

    if (result['success']) {
      await fetchCart(silent: true);
      notifyListeners();
      if (kDebugMode) {
        print('✅ Item added to cart. Total: $_cartItemCount');
      }
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Failed to add item';
      notifyListeners();
      if (kDebugMode) {
        print('❌ Failed to add to cart: $_errorMessage');
      }
      return false;
    }
  }

  // ✅ Update Cart Item Quantity
  Future<bool> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    if (quantity < 1) return false;

    final itemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (itemIndex == -1) return false;

    final oldItem = _cartItems[itemIndex];
    final updatedItem = oldItem.copyWith(quantity: quantity);

    // Optimistically update UI
    _cartItems[itemIndex] = updatedItem;
    notifyListeners();

    final result = await _cartService.updateCartItem(
      cartItemId: cartItemId,
      quantity: quantity,
    );

    if (result['success']) {
      await fetchCart(silent: true);
      return true;
    } else {
      _cartItems[itemIndex] = oldItem; // revert
      _errorMessage = result['message'] ?? 'Failed to update quantity';
      notifyListeners();
      return false;
    }
  }

  // ✅ Remove Item from Cart
  Future<bool> removeFromCart(String cartItemId) async {
    final itemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (itemIndex == -1) return false;

    final removedItem = _cartItems[itemIndex];
    _cartItems.removeAt(itemIndex);
    _cartItemCount = _cartItems.length;
    notifyListeners();

    final result = await _cartService.removeFromCart(cartItemId);

    if (result['success']) {
      await fetchCart(silent: true);
      return true;
    } else {
      _cartItems.insert(itemIndex, removedItem); // revert
      _cartItemCount = _cartItems.length;
      _errorMessage = result['message'] ?? 'Failed to remove item';
      notifyListeners();
      return false;
    }
  }

  // ✅ Clear Cart
  Future<bool> clearCart() async {
    final result = await _cartService.clearCart();

    if (result['success']) {
      _cartItems = [];
      _cartItemCount = 0;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Failed to clear cart';
      notifyListeners();
      return false;
    }
  }

  // ✅ Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
