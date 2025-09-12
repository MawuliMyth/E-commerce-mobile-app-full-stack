// models/category_model.dart

class CategoryModel {
  final String id;
  final String name;
  final String image;
  final List<SubCategoryModel> subCategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'],
      name: json['name'],
      image: json['image'],
      subCategories: (json['subCategories'] as List)
          .map((sub) => SubCategoryModel.fromJson(sub))
          .toList(),
    );
  }
}

class SubCategoryModel {
  final String id;
  final String name;
  final List<ProductModel> products;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.products,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['_id'],
      name: json['name'],
      products: (json['products'] as List)
          .map((prod) => ProductModel.fromJson(prod))
          .toList(),
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final String brand;
  final List<String> images;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.brand,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Extract brand name from proBrandId object
    String brandName = '';
    if (json['proBrandId'] != null) {
      if (json['proBrandId'] is Map<String, dynamic>) {
        brandName = json['proBrandId']['name'] ?? '';
      }
    }

    return ProductModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'] ?? "",
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      brand: brandName,
      images: (json['images'] as List)
          .map((img) => img['url'] as String)
          .toList(),
    );
  }
}
