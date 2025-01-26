import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> exclusiveDeals = [];
  List<Map<String, dynamic>> bestSellers = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchProductsFromApi();
  }

  Future<void> fetchProductsFromApi() async {
    try {
      final products = await ApiService.fetchProducts();
      if (products.isNotEmpty) {
        setState(() {
          exclusiveDeals = products.take(7).toList().cast<Map<String, dynamic>>();
          bestSellers = products.skip(8).toList().cast<Map<String, dynamic>>();
          searchResults = [...exclusiveDeals, ...bestSellers];
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No products available.')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $error')),
      );
    }
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchResults = [...exclusiveDeals, ...bestSellers]
          .where((product) =>
          product['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      int quantity = 1; // Default quantity
      int availableStock = product['stock']; // Get available stock from the product

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  product['image'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Text(
                  product['name'],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "${product['price']} TND",
                  style: const TextStyle(fontSize: 18, color: Colors.pink),
                ),
                const SizedBox(height: 10),
                Text(
                  product['description'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "Available Stock: $availableStock",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.pink),
                      onPressed: () {
                        setState(() {
                          if (quantity > 1) quantity--;
                        });
                      },
                    ),
                    Text(
                      "$quantity",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.pink),
                      onPressed: () {
                        setState(() {
                          if (quantity < availableStock) {
                            quantity++;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cannot add more than available stock'),
                              ),
                            );
                          }
                        });
                      },
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      String? token = prefs.getString('token');
                      if (token == null) {
                        throw Exception("No token found");
                      }

                      token = token.trim(); // Trim any spaces
                      print("DEBUG: Token being sent to backend: $token");

                      // Use the updated ApiService method to add to cart
                      await ApiService.addToCart(
                        product['_id'], // Pass the product ID
                        quantity, // Pass the selected quantity
                        product['price'], // Pass the product price
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add to cart: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  child: const Text("Add to Cart"),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildSearchBar(),
              const SizedBox(height: 20),
              if (!isSearching) ...[
                const Text(
                  'Exclusive Deals',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildProductList(context, exclusiveDeals),
                const SizedBox(height: 20),
                const Text(
                  'Best Sellers',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildProductList(context, bestSellers),
              ] else ...[
                const Text(
                  'Search Results',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildProductList(context, searchResults),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(50)),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        onChanged: (query) => _searchProducts(query),
        decoration: const InputDecoration(
          hintText: 'Search for products',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildProductList(
      BuildContext context, List<Map<String, dynamic>> products) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () => _showProductDetails(context, product),
            child: Card(
              elevation: 5,
              child: Container(
                width: 150,
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        product['image'] ?? 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            product['name'],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${product['price']} TND",
                            style: const TextStyle(color: Colors.pink),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
