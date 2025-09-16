import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

// Controller for managing product-related data and API interactions
class ProductController {
  final String apiUrl = "https://online-store-api-ashy.vercel.app/api/products";

  // Fetches products by category ID from the API
  Future<List<Product>> fetchProductsByCategory(String categoryId, {int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl?proCategoryId=$categoryId&page=$page&limit=$limit"));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse["data"];
        return data.map((p) => Product.fromJson(p)).toList();
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }
}