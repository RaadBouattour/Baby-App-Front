import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  _CategoryProductsScreenState createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategoryProducts();
  }

  /// Fetch products for the selected category
  Future<void> fetchCategoryProducts() async {
    try {
      final fetchedProducts =
          await ApiService.fetchCategoryProducts(widget.categoryId); // Assuming you have this API
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("No products available."))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      elevation: 4,
                      child: ListTile(
                        leading: Image.network(
                          product['image'], // Replace with your API's image URL
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(product['name']),
                        subtitle: Text("${product['price']} TND"),
                        onTap: () {
                          // Handle product details navigation
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
