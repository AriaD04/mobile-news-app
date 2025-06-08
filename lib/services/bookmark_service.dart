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

  // You can add more methods here later, e.g., to remove bookmarks or get all bookmarks.
}