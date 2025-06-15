import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../models/news_article.dart'; // Adjust path to your NewsArticle model
import '../controllers/bookmark_controller.dart'; // Import BookmarkController

class NewsDetailPage extends StatelessWidget {
  final NewsArticle newsArticle;

  const NewsDetailPage({super.key, required this.newsArticle});

  @override
  Widget build(BuildContext context) {
    final String? title = newsArticle.title;
    final String? description = newsArticle.description;
    final String? imageUrl = newsArticle.imageUrl;
    final String? sourceId = newsArticle.sourceId;
    final String? author = newsArticle.displayAuthor;
    final String? pubDateStr = newsArticle.pubDate;
    DateTime? publishedAt;
    if (pubDateStr != null) {
      try {
        publishedAt = DateTime.parse(pubDateStr).toLocal();
      } catch (e) {
        print('Error parsing date: $e');
        publishedAt = null;
      }
    }
    final String? articleContent = newsArticle.content;
    final List<String>? categories = newsArticle.category;
    final String? category = categories?.isNotEmpty == true ? categories!.first : null;

    // Access BookmarkController using Provider and watch for changes
    final bookmarkController = context.watch<BookmarkController>();
    final bool isBookmarked = bookmarkController.isArticleBookmarked(newsArticle);
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'News Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // First Row: Image
            if (imageUrl != null && imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl,
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
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(Icons.broken_image, color: Colors.grey[400], size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            // Second Row: Title
            Text(
              title ?? 'No Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Third Row: Author, Published Date
            Row(
              children: <Widget>[
                if (author != null && author.isNotEmpty)
                  Text(
                    'By $author',
                    style: TextStyle(color: Colors.grey),
                  ),
                if (author != null && author.isNotEmpty && publishedAt != null)
                  Text(
                    ' • ',
                    style: TextStyle(color: Colors.grey),
                  ),
                if (publishedAt != null)
                  Text(
                    DateFormat('MMM d, hh:mm a').format(publishedAt.toLocal()),
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
            SizedBox(height: 8),
            // Fourth Row: Category and Bookmark Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Category
                if (category != null && category.isNotEmpty)
                  Chip(
                    label: Text(category),
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                // Bookmark Button that reflects state and allows toggling
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  onPressed: () async {
                    // Use context.read<BookmarkController>() for actions inside callbacks
                    final controller = context.read<BookmarkController>();
                    try {
                      if (isBookmarked) {
                        await controller.removeBookmark(newsArticle);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Article removed from bookmarks!')),
                        );
                      } else {
                        await controller.addBookmark(newsArticle);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Article bookmarked!')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating bookmark: ${e.toString()}')),
                      );
                    }
                  }, // Add comma here
                ),
              ],
            ),
            SizedBox(height: 16),
            // Fifth Row: Description
            if (description != null && description.isNotEmpty)
              Text(
                description,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            SizedBox(height: 16),
            // Sixth Row: Content
            if (articleContent != null && articleContent.isNotEmpty)
              Text(
                articleContent,
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 24),
            // Additional Information (Source)
            if (sourceId != null && sourceId.isNotEmpty)
              Text(
                'Source: $sourceId',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}