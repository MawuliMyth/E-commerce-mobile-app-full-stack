import 'package:ecommerce_firebase/features/dashboard/models/product_model.dart';

// Models for category and subcategory data from the Category API
class SubCategory {
  final String id;
  final String name;
  final List<Product> products;

  SubCategory({
    required this.id,
    required this.name,
    required this.products,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json["_id"],
      name: json["name"],
      products: (json["products"] as List)
          .map((p) => Product.fromJsonCategory(p))
          .toList(),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String image;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["_id"],
      name: json["name"],
      image: json["image"],
      subCategories: (json["subCategories"] as List)
          .map((s) => SubCategory.fromJson(s))
          .toList(),
    );
  }

  // Calculates total number of products in all subcategories
  int get totalProducts {
    return subCategories
        .map((subCategory) => subCategory.products.length)
        .reduce((a, b) => a + b);
  }
}