class Poster {
  final String id;
  final String imageUrl;

  Poster({required this.id, required this.imageUrl});

  factory Poster.fromJson(Map<String, dynamic> json) {
    return Poster(
      id: json['_id'] ?? '', // Fallback to empty string if null
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150', // Fallback URL
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'imageUrl': imageUrl,
    };
  }
}