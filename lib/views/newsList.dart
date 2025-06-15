import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/news_controller.dart';
import '../controllers/bookmark_controller.dart'; // Import the new controller
import '../models/news_article.dart';
import 'newsDetail.dart';
import 'bookmarkPage.dart'; // Assuming your BookmarkPage is in bookmarkPage.dart

class NewsListPage extends StatelessWidget { // Changed to StatelessWidget
  const NewsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // Use MultiProvider to provide multiple controllers
      providers: [ // BookmarkController is now provided globally in main.dart
        ChangeNotifierProvider(create: (context) => NewsController()),
      ],
      child: _NewsListPageContent(),
    );
  }
}

// Extracted content to a StatefulWidget to manage TabController
class _NewsListPageContent extends StatefulWidget {
  @override
  __NewsListPageContentState createState() => __NewsListPageContentState();
}

class __NewsListPageContentState extends State<_NewsListPageContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initial data loading for News
    // Ensure NewsController's constructor or an init method fetches news if needed,
    // or call it explicitly here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsController>(context, listen: false).loadNews(); // Or your initial fetch method
      // Fetch initial bookmarks
      Provider.of<BookmarkController>(context, listen: false).fetchBookmarkedArticles();
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index == 1) {
        // If Bookmarks tab (index 1) is selected, refresh bookmarks
        Provider.of<BookmarkController>(context, listen: false).fetchBookmarkedArticles();
      }
    });
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Terkini'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'News'),
            Tab(text: 'Bookmarks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // News Feed Tab
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  children: context.watch<NewsController>().categories.map((cat) {
                    final controller = context.read<NewsController>();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () => controller.selectCategoryAndFetch(cat),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.selectedCategory == cat
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          foregroundColor: controller.selectedCategory == cat
                              ? Theme.of(context).colorScheme.onPrimary
                              : null,
                        ),
                        child: Text(cat.toUpperCase()),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: Consumer<NewsController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading && controller.newsItems.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.errorMessage != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("Error: ${controller.errorMessage!}", textAlign: TextAlign.center),
                        )
                      );
                    }
                    if (controller.newsItems.isEmpty) {
                      return const Center(child: Text('No news available for this category.'));
                    }
                    return ListView.builder(
                      itemCount: controller.newsItems.length,
                      itemBuilder: (context, index) {
                        final article = controller.newsItems[index];
                        return NewsCard(article: article);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Bookmarks Tab
          Consumer<BookmarkController>(
            builder: (context, bookmarkController, child) {
              if (bookmarkController.isLoading && bookmarkController.bookmarkedArticles.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (bookmarkController.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Error loading bookmarks: ${bookmarkController.errorMessage}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return BookmarkPage(
                bookmarkedArticles: bookmarkController.bookmarkedArticles,
                onArticleDeleted: (article) async {
                  final confirmDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: Text('Are you sure you want to delete "${article.title ?? 'this article'}" from your bookmarks?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmDelete == true) {
                    await bookmarkController.removeBookmark(article);
                    // Optionally show a SnackBar for feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"${article.title ?? 'Article'}" removed from bookmarks.')),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticle article;

  const NewsCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailPage(newsArticle: article),
            ),
          );
        },
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
                article.displayCategory,
                style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
              ),
              if (article.displayAuthor.isNotEmpty && article.displayAuthor != 'Unknown Author')
                Text(
                  'By: ${article.displayAuthor}', // Ensure displayAuthor getter exists in NewsArticle
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
                ),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailPage(newsArticle: article),
                      ),
                    );
                  },
                  child: const Text('Baca'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}