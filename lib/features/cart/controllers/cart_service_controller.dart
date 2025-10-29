import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../auth/controllers/auth_controller.dart';

class CartService {
  static const String baseUrl = 'https://online-store-api-ashy.vercel.app/api';

  final AuthController _authController = AuthController();

  Map<String, dynamic> _createResponse({
    required bool success,
    String? message,
    dynamic data,
  }) {
    return {'success': success, 'message': message, 'data': data};
  }

  // ✅ Use AuthController's authenticatedRequest
  Future<Map<String, dynamic>> authenticatedRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');

      if (kDebugMode) {
        print('🌐 CartService: $method request to $endpoint');
      }

      final response = await _authController.authenticatedRequest(
        uri,
        method: method,
        body: body,
      );

      if (kDebugMode) {
        print('📡 CartService: Response status=${response.statusCode}');
      }

      final data = json.decode(response.body.isNotEmpty ? response.body : '{}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _createResponse(success: true, data: data);
      } else {
        return _createResponse(
          success: false,
          message: data['message'] ?? 'Request failed',
          data: data,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ CartService: Error: $e');
      return _createResponse(success: false, message: e.toString());
    }
  }

  // GET CART
  Future<Map<String, dynamic>> getCart() async {
    return authenticatedRequest('cart', 'GET');
  }

  // ADD TO CART
  Future<Map<String, dynamic>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    return authenticatedRequest(
      'cart/add',
      'POST',
      body: {'productId': productId, 'quantity': quantity},
    );
  }

  // UPDATE CART ITEM
  Future<Map<String, dynamic>> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    return authenticatedRequest(
      'cart/$cartItemId',
      'PUT',
      body: {'quantity': quantity},
    );
  }

  // REMOVE FROM CART
  Future<Map<String, dynamic>> removeFromCart(String cartItemId) async {
    return authenticatedRequest('cart/$cartItemId', 'DELETE');
  }

  // CLEAR CART
  Future<Map<String, dynamic>> clearCart() async {
    return authenticatedRequest('cart/clear', 'DELETE');
  }
}
