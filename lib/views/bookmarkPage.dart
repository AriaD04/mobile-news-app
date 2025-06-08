import 'package:flutter/material.dart';

class BookmarkPage extends StatelessWidget {
  final List<Map<String, dynamic>> bookmarkedArticles;

  BookmarkPage({Key? key, this.bookmarkedArticles = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Bookmark Kosong', style: TextStyle(fontSize: 16)),
    );
  }
}