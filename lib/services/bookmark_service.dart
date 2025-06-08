import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/news_article.dart'; // Adjust path if your model is elsewhere

class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addArticleToBookmarks(NewsArticle article) async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      // Optionally, you could throw an exception or return a status
      // to inform the UI that the user needs to be logged in.
      print("User not logged in. Cannot add bookmark.");
      throw Exception("Please log in to save bookmarks.");
    }

    final articleMap = article.toJson(); // Uses the toJson() method from NewsArticle
    final userDocRef = _firestore.collection('bookmarks').doc(currentUser.uid);

    try {
      // Atomically add the new article to the 'bookmarkedArticles' array.
      // SetOptions(merge: true) ensures that the document is created if it doesn't exist,
      // and the 'bookmarkedArticles' field is merged (or created if not present).
      await userDocRef.set(
        {'bookmarkedArticles': FieldValue.arrayUnion([articleMap])},
        SetOptions(merge: true),
      );
    } catch (e) {
      print("Error adding bookmark to Firestore: $e");
      throw Exception("Could not save bookmark. Please try again.");
    }
  }

  Future<List<NewsArticle>> getBookmarkedArticles() async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      print("User not logged in. Cannot retrieve bookmarks.");
      // Depending on your app's flow, you might want to throw an exception
      // or return an empty list. For now, returning an empty list.
      return [];
    }

    final userDocRef = _firestore.collection('bookmarks').doc(currentUser.uid);

    try {
      final docSnapshot = await userDocRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data['bookmarkedArticles'] is List) {
          final List<dynamic> bookmarkedArticlesData = data['bookmarkedArticles'];
          // Convert each map in the array to a NewsArticle object
          return bookmarkedArticlesData
              .map((articleMap) => NewsArticle.fromJson(Map<String, dynamic>.from(articleMap)))
              .toList();
        }
      }
      return []; // Return empty list if document or field doesn't exist
    } catch (e) {
      print("Error retrieving bookmarks from Firestore: $e");
      throw Exception("Could not retrieve bookmarks. Please try again.");
    }
  }

  Future<void> removeArticleFromBookmarks(NewsArticle article) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in. Cannot remove bookmark.");

    final articleMap = article.toJson();
    final userDocRef = _firestore.collection('bookmarks').doc(currentUser.uid);

    // Atomically remove the article from the 'bookmarkedArticles' array.
    await userDocRef.update({
      'bookmarkedArticles': FieldValue.arrayRemove([articleMap])
    });
  }
}