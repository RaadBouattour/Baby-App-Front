import 'package:flutter/material.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace this with actual articles
    final List<Map<String, String>> articles = [
      {
        "title": "10 Best Baby Products for 2025",
        "content": "Discover the top-rated products every parent should have."
      },
      {
        "title": "Tips for First-Time Moms",
        "content": "Helpful advice to make your parenting journey smoother."
      },
      {
        "title": "Healthy Baby Food Recipes",
        "content": "Easy-to-make recipes to keep your baby healthy and happy."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                article['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(article['content']!),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to article details page
              },
            ),
          );
        },
      ),
    );
  }
}
