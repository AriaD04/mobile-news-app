import 'package:flutter/material.dart';
import '../models/news_article.dart'; // Import your NewsArticle model
import 'newsDetail.dart';           // Import NewsDetailPage for navigation

class BookmarkCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onDelete; // Callback for delete action

  const BookmarkCard({
    Key? key,
    required this.article,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 120.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    article.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(child: Icon(Icons.broken_image, color: Colors.grey[400], size: 40)),
                      );
                    },
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 120.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[500])),
                ),
              ),
            const SizedBox(height: 10.0),
            Text(
              article.title ?? 'No Title Available',
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Text(
              article.displayCategory, // Make sure NewsArticle has this field
              style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
            ),
            if (article.displayAuthor.isNotEmpty && article.displayAuthor != 'Unknown Author') // Make sure NewsArticle has this field
              Text(
                'By: ${article.displayAuthor}',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
              ),
            const SizedBox(height: 16.0), // Spacing before buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailPage(newsArticle: article),
                      ),
                    );
                  },
                  child: const Text('Read'),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BookmarkPage extends StatelessWidget {
  final List<NewsArticle> bookmarkedArticles;
  final void Function(NewsArticle article) onArticleDeleted;

  const BookmarkPage({
    Key? key,
    this.bookmarkedArticles = const [],
    required this.onArticleDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bookmarkedArticles.isEmpty) {
      return const Center(
        child: Text('Bookmark Kosong', style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      itemCount: bookmarkedArticles.length,
      itemBuilder: (context, index) {
        final article = bookmarkedArticles[index];
        return BookmarkCard(
          article: article,
          onDelete: () {
            onArticleDeleted(article);
            // Optionally, show a SnackBar for feedback
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text('"${article.title}" removed from bookmarks.')),
            // );
          },
        );
      },
    );
  }
}