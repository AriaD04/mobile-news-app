// lib/models/news_article.dart
class NewsArticle {
  final String? title;
  final String? link;
  final List<String>? keywords;
  final List<String>? creator;
  final String? videoUrl;
  final String? description;
  final String? content;
  final String? pubDate;
  final String? imageUrl;
  final String? sourceId;
  final int? sourcePriority;
  final String? country; // API might return a list or a string for country
  final List<String>? category;
  final String? language;

  NewsArticle({
    this.title,
    this.link,
    this.keywords,
    this.creator,
    this.videoUrl,
    this.description,
    this.content,
    this.pubDate,
    this.imageUrl,
    this.sourceId,
    this.sourcePriority,
    this.country,
    this.category,
    this.language,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] as String?,
      link: json['link'] as String?,
      keywords: (json['keywords'] as List?)?.cast<String>(),
      creator: (json['creator'] as List?)?.cast<String>(),
      videoUrl: json['video_url'] as String?,
      description: json['description'] as String?,
      content: json['content'] as String?,
      pubDate: json['pubDate'] as String?, // Note: API uses 'pubDate'
      imageUrl: json['image_url'] as String?,
      sourceId: json['source_id'] as String?,
      sourcePriority: json['source_priority'] as int?,
      // Handle country potentially being a list or string
      country: json['country'] is List
          ? (json['country'] as List).join(', ')
          : json['country'] as String?,
      category: (json['category'] as List?)?.cast<String>(),
      language: json['language'] as String?,
    );
  }

  String get displayAuthor {
    if (creator != null && creator!.isNotEmpty) {
      return creator!.join(', ');
    }
    return 'Unknown Author';
  }

  String get displayCategory {
    if (category != null && category!.isNotEmpty) {
      // Capitalize first letter of each category for display
      return category!.map((c) => c[0].toUpperCase() + c.substring(1)).join(', ');
    }
    return 'No Category';
  }
}
