class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? image; // ✅ First image
  final List<String> images; // ✅ All image URLs

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
    this.images = const [],
  });

  double get totalPrice => price * quantity;

  /// ✅ Factory for parsing JSON safely
  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['productId'] ?? {};

    // Extract image URLs safely
    final imagesList =
        (product['images'] as List?)
            ?.map((img) => img['url']?.toString() ?? '')
            .where((url) => url.isNotEmpty)
            .toList() ??
        [];

    final firstImage = imagesList.isNotEmpty ? imagesList.first : null;

    return CartItem(
      id: json['_id'] ?? '',
      name: product['name'] ?? 'Unnamed Product',
      price: (product['price'] ?? json['priceAtTime'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      image: firstImage,
      images: imagesList,
    );
  }

  /// ✅ Fallback empty item (fixes your `.empty()` error)
  factory CartItem.empty() {
    return CartItem(
      id: '',
      name: 'Invalid Product',
      price: 0.0,
      quantity: 0,
      image: null,
      images: const [],
    );
  }

  /// ✅ For updating specific fields immutably (fixes your `.copyWith()` error)
  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? image,
    List<String>? images,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      images: images ?? this.images,
    );
  }
}
