// lib/controllers/news_controller.dart
import 'package:flutter/foundation.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';

class NewsController with ChangeNotifier {
  final NewsService _newsService = NewsService();

  List<NewsArticle> _newsItems = [];
  String? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters for UI to access state
  List<NewsArticle> get newsItems => _newsItems;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get categories => _newsService.availableCategories;

  NewsController() {
    // Load initial news when the controller is created
    loadNews();
  }

  Future<void> loadNews({String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    //clear newsItems immediately for a better UX when changing categories
    if (category != _selectedCategory) {
        _newsItems = [];
    }
    _selectedCategory = category;
    notifyListeners(); // Notify UI about loading start and category change

    try {
      _newsItems = await _newsService.fetchNewsFromApi(category: category);
      _errorMessage = null; // Clear error on success
    } catch (e) {
      _errorMessage = e.toString();
      _newsItems = []; // Clear items on error to avoid showing stale data
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI about loading end and data/error update
    }
  }

  // This method can be called by UI to change category
  void selectCategoryAndFetch(String? category) {
    if (_selectedCategory != category || _newsItems.isEmpty) {
      loadNews(category: category);
    }
  }
}
