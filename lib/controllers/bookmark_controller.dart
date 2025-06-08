import 'package:flutter/foundation.dart';
import '../models/news_article.dart';
import '../services/bookmark_service.dart'; // Ensure this path is correct

class BookmarkController with ChangeNotifier {
  final BookmarkService _bookmarkService = BookmarkService();

  List<NewsArticle> _bookmarkedArticles = [];
  List<NewsArticle> get bookmarkedArticles => _bookmarkedArticles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Constructor can optionally fetch bookmarks immediately,
  // or you can call fetchBookmarkedArticles() explicitly when needed.
  // BookmarkController() {
  //   fetchBookmarkedArticles();
  // }

  Future<void> fetchBookmarkedArticles() async {
    _isLoading = true;
    _errorMessage = null;
    // Notify listeners at the start of loading if you want to show a general loading state
    // for the whole list before _bookmarkedArticles is populated.
    // If _bookmarkedArticles is already populated and you're just refreshing,
    // you might notify later or handle it differently.
    notifyListeners();

    try {
      _bookmarkedArticles = await _bookmarkService.getBookmarkedArticles();
    } catch (e) {
      _errorMessage = "Error fetching bookmarks: ${e.toString()}";
      _bookmarkedArticles = []; // Clear articles on error
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBookmark(NewsArticle article) async {
    // Consider optimistic update here for better UX
    _isLoading = true; // Indicate loading for the add operation
    notifyListeners();
    try {
      await _bookmarkService.addArticleToBookmarks(article);
      await fetchBookmarkedArticles(); // Refresh the list from source
    } catch (e) {
      _errorMessage = "Failed to add bookmark: ${e.toString()}";
      print(_errorMessage);
      // If using optimistic update, revert here
      notifyListeners(); // Notify to update UI with error or reverted state
    }
    _isLoading = false; // Reset loading state for add operation
    notifyListeners();
  }

  Future<void> removeBookmark(NewsArticle article) async {
    // Consider optimistic update here
    try {
      await _bookmarkService.removeArticleFromBookmarks(article);
      await fetchBookmarkedArticles(); // Refresh the list from source
    } catch (e) {
      _errorMessage = "Failed to remove bookmark: ${e.toString()}";
      print(_errorMessage);
      // If using optimistic update, revert here
      notifyListeners(); // Notify to update UI with error or reverted state
    }
  }
}