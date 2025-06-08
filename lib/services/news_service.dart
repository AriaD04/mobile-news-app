// lib/services/news_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart'; // Adjust path if your structure is different

class NewsService {
  final String _apiKey = 'pub_406a54734c1a40659cd6ef1cdaa11cea';
  final String _baseUrl = 'https://newsdata.io/api/1/news?language=en&apikey=';

  final List<String> _allCategories = [
    "business", "entertainment", "world", "health",
    "science", "sports", "technology", "tourism",
  ];

  List<String> get availableCategories => List.unmodifiable(_allCategories);

  Future<List<NewsArticle>> fetchNewsFromApi({String? category, int randomCategoryCount = 3}) async {
    String apiUrl = '$_baseUrl$_apiKey';

    if (category != null && category.isNotEmpty) {
      apiUrl += '&category=$category';
    } else {
      // Fetch from a few random categories if no specific category is provided
      final randomCategories = (_allCategories.toList()..shuffle()).take(randomCategoryCount).join(',');
      if (randomCategories.isNotEmpty) {
        apiUrl += '&category=$randomCategories';
      }
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['results'] != null) {
          final List<dynamic> results = data['results'];
          return results
              // Filter results to include only articles with a valid image_url.
              .where((jsonItem) {
                // Ensure jsonItem is a Map and contains a non-null, non-empty 'image_url'.
                if (jsonItem is Map<String, dynamic>) {
                  final imageUrl = jsonItem['image_url'];
                  return imageUrl != null && imageUrl is String && imageUrl.isNotEmpty;
                }
                return false; // Item is not a map or doesn't meet criteria.
              })
              .map((jsonItem) => NewsArticle.fromJson(jsonItem as Map<String, dynamic>))
              .toList();
        } else {
          // Try to get a more specific error message from the API response
          String apiErrorMessage = 'Failed to load news.';
          if (data['results'] is Map && data['results']['message'] != null) {
            apiErrorMessage = data['results']['message'];
          } else if (data['message'] != null) {
            apiErrorMessage = data['message'];
          }
          throw Exception(apiErrorMessage);
        }
      } else {
        throw Exception('Failed to connect to the server. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // throw the exception or a custom one
      throw Exception('An error occurred while fetching news: ${e.toString()}');
    }
  }
}
