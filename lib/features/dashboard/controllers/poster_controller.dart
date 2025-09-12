import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/poster_model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For caching

class PosterController {
  final String apiUrl = "https://online-store-api-ashy.vercel.app/api/posters";
  static const String _cacheKey = 'cached_posters';
  static const Duration _cacheDuration = Duration(hours: 1); // Cache for 1 hour

  Future<List<Poster>> fetchPosters({bool forceRefresh = false}) async {
    // Try to load from cache first
    if (!forceRefresh) {
      final cachedPosters = await _loadFromCache();
      if (cachedPosters != null) {
        return cachedPosters;
      }
    }

    try {
      // Set a timeout for the HTTP request
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (!jsonResponse.containsKey('data')) {
            throw Exception('Invalid API response: "data" key missing');
          }
          final List<dynamic> postersJson = jsonResponse['data'];
          final posters = postersJson.map((poster) => Poster.fromJson(poster)).toList();

          // Cache the results
          await _saveToCache(posters);
          return posters;
        } catch (e) {
          throw Exception('Failed to parse JSON: $e');
        }
      } else {
        throw Exception('Failed to load posters: HTTP ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      // Optionally, fall back to cache on network failure
      final cachedPosters = await _loadFromCache();
      if (cachedPosters != null) {
        return cachedPosters;
      }
      rethrow; // If no cache, throw the error
    }
  }

  // Save posters to cache
  Future<void> _saveToCache(List<Poster> posters) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedPosters = json.encode(posters.map((poster) => poster.toJson()).toList());
    await prefs.setString(_cacheKey, encodedPosters);
    await prefs.setInt('${_cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  // Load posters from cache
  Future<List<Poster>?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    final timestamp = prefs.getInt('${_cacheKey}_timestamp');

    if (cachedData != null && timestamp != null) {
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (cacheAge < _cacheDuration.inMilliseconds) {
        try {
          final List<dynamic> decoded = json.decode(cachedData);
          return decoded.map((item) => Poster.fromJson(item)).toList();
        } catch (e) {
          // Clear invalid cache
          await prefs.remove(_cacheKey);
          await prefs.remove('${_cacheKey}_timestamp');
          return null;
        }
      } else {
        // Clear expired cache
        await prefs.remove(_cacheKey);
        await prefs.remove('${_cacheKey}_timestamp');
      }
    }
    return null;
  }
}