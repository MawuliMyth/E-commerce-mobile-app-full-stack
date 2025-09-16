class Product {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["_id"],
      name: json["name"],
      description: json["description"],
      quantity: json["quantity"],
      price: (json["price"] as num).toDouble(),
      images: (json["images"] as List)
          .map((img) => img["url"] as String? ?? "")
          .where((url) => url.isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "description": description,
      "quantity": quantity,
      "price": price,
      "images": images.map((url) => {"url": url}).toList(),
    };
  }
}

class SubCategory {
  final String id;
  final String name;
  final List<Product> products;

  SubCategory({required this.id, required this.name, required this.products});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json["_id"],
      name: json["name"],
      products: (json["products"] as List)
          .map((p) => Product.fromJson(p))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "products": products.map((p) => p.toJson()).toList(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "image": image,
      "subCategories": subCategories.map((s) => s.toJson()).toList(),
    };
  }

  // Method to calculate total number of products
  int get totalProducts {
    return subCategories
        .map((subCategory) => subCategory.products.length)
        .reduce((a, b) => a + b);
  }
}
