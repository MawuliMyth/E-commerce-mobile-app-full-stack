import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/poster_model.dart';

class PosterController {
  final String apiUrl = "https://online-store-api-ashy.vercel.app/api/posters";

  Future<List<Poster>> fetchPosters() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      final List<dynamic> postersJson = jsonResponse['data'];

      return postersJson.map((poster) => Poster.fromJson(poster)).toList();
    } else {
      throw Exception("Failed to load posters");
    }
  }
}
