class Poster {
  final String id;
  final String imageUrl;

  Poster({required this.id, required this.imageUrl});

  factory Poster.fromJson(Map<String, dynamic> json) {
    return Poster(
      id: json['_id'],
      imageUrl: json['imageUrl'],
    );
  }
}
