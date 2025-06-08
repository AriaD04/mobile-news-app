import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/news_controller.dart';
import '../models/news_article.dart';
import 'newsDetail.dart';
import 'bookmarkPage.dart'; // Assuming your BookmarkPage is in bookmarkPage.dart

class NewsListPage extends StatelessWidget { // Changed to StatelessWidget
  NewsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NewsController(),
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
    // Initial data loading is handled by NewsController's constructor
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
        title: Text('Berita Terkini'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
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
                padding: const EdgeInsets.all(8.0),
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
                      return Center(child: CircularProgressIndicator());
                    }
                    if (controller.errorMessage != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(controller.errorMessage!, textAlign: TextAlign.center),
                        )
                      );
                    }
                    if (controller.newsItems.isEmpty) {
                      return Center(child: Text('No news available for this category.'));
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
          BookmarkPage(bookmarkedArticles: []), // Placeholder, will need its own controller/logic
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticle article;

  NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
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
                          child: Center(child: Icon(Icons.broken_image, color: Colors.grey[400])),
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
              SizedBox(height: 10.0),
              Text(
                article.title ?? 'No Title Available',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.0),
              Text(
                article.displayCategory,
                style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
              ),
              if (article.displayAuthor.isNotEmpty && article.displayAuthor != 'Unknown Author')
                Text(
                  'By: ${article.displayAuthor}',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
                ),
              SizedBox(height: 10.0),
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
                  child: Text('Baca'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}