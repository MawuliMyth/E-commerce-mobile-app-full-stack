class Product {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final List<String> images;
  final String? categoryId;
  final String? categoryName;
  final String? subCategoryId;
  final String? subCategoryName;
  final String? brandId;
  final String? brandName;
  final FlashSale? flashSale;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.images,
    this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.brandId,
    this.brandName,
    this.flashSale,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final proCategoryId = json['proCategoryId'];
    final proSubCategoryId = json['proSubCategoryId'];
    final proBrandId = json['proBrandId'];
    return Product(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      description: json['description']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>?)
          ?.map((img) => img['url']?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList() ??
          [],
      categoryId: proCategoryId is Map<String, dynamic> ? proCategoryId['_id']?.toString() : proCategoryId?.toString(),
      categoryName: proCategoryId is Map<String, dynamic> ? proCategoryId['name']?.toString() : null,
      subCategoryId: proSubCategoryId is Map<String, dynamic> ? proSubCategoryId['_id']?.toString() : proSubCategoryId?.toString(),
      subCategoryName: proSubCategoryId is Map<String, dynamic> ? proSubCategoryId['name']?.toString() : null,
      brandId: proBrandId is Map<String, dynamic> ? proBrandId['_id']?.toString() : proBrandId?.toString(),
      brandName: proBrandId is Map<String, dynamic> ? proBrandId['name']?.toString() : null,
      flashSale: json['flashSale'] != null ? FlashSale.fromJson(json['flashSale'] as Map<String, dynamic>) : null,
    );
  }

  factory Product.fromJsonCategory(Map<String, dynamic> json) {
    final proCategoryId = json['proCategoryId'];
    final proSubCategoryId = json['proSubCategoryId'];
    final proBrandId = json['proBrandId'];
    return Product(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      description: json['description']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>?)
          ?.map((img) => img['url']?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList() ??
          [],
      categoryId: proCategoryId is Map<String, dynamic> ? proCategoryId['_id']?.toString() : proCategoryId?.toString(),
      categoryName: proCategoryId is Map<String, dynamic> ? proCategoryId['name']?.toString() : null,
      subCategoryId: proSubCategoryId is Map<String, dynamic> ? proSubCategoryId['_id']?.toString() : proSubCategoryId?.toString(),
      subCategoryName: proSubCategoryId is Map<String, dynamic> ? proSubCategoryId['name']?.toString() : null,
      brandId: proBrandId is Map<String, dynamic> ? proBrandId['_id']?.toString() : proBrandId?.toString(),
      brandName: proBrandId is Map<String, dynamic> ? proBrandId['name']?.toString() : null,
      flashSale: json['flashSale'] != null ? FlashSale.fromJson(json['flashSale'] as Map<String, dynamic>) : null,
    );
  }
}

class FlashSale {
  final String id;
  final String name;
  final double discountPercentage;
  final double flashSalePrice;
  final String endTime;
  final int timeRemaining;
  final int remainingQuantity;
  final int maxQuantityPerUser;

  FlashSale({
    required this.id,
    required this.name,
    required this.discountPercentage,
    required this.flashSalePrice,
    required this.endTime,
    required this.timeRemaining,
    required this.remainingQuantity,
    required this.maxQuantityPerUser,
  });

  factory FlashSale.fromJson(Map<String, dynamic> json) {
    return FlashSale(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      flashSalePrice: (json['flashSalePrice'] as num?)?.toDouble() ?? 0.0,
      endTime: json['endTime']?.toString() ?? '',
      timeRemaining: (json['timeRemaining'] as num?)?.toInt() ?? 0,
      remainingQuantity: (json['remainingQuantity'] as num?)?.toInt() ?? 0,
      maxQuantityPerUser: (json['maxQuantityPerUser'] as num?)?.toInt() ?? 0,
    );
  }
}