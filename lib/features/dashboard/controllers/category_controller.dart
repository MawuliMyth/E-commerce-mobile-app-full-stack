import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class CategoryController {
  final String apiUrl = "https://online-store-api-ashy.vercel.app/api/categories";

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse["data"];

      return data.map((c) => Category.fromJson(c)).toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }
}
