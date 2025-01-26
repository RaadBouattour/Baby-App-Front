import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Assume this handles API requests

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({Key? key}) : super(key: key);

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  List<Map<String, dynamic>> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  /// Fetch articles from the backend
  Future<void> fetchArticles() async {
    try {
      final fetchedArticles = await ApiService.fetchArticles(); // Assuming this method exists
      setState(() {
        articles = fetchedArticles.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching articles: $e')),
      );
    }
  }

  /// Show the article content in a popup
  void _showArticleContent(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : articles.isEmpty
              ? const Center(child: Text('No articles available.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          article['title'] ?? 'No Title',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          // Show article content in a popup
                          _showArticleContent(
                            context,
                            article['title'] ?? 'No Title',
                            article['content'] ?? 'No Content',
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
