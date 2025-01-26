import 'package:flutter/material.dart';
import 'order_form_screen.dart'; // Import the order form screen
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> cartItems = [];
  bool isLoading = true;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  /// Fetch the user's cart
  Future<void> fetchCart() async {
    try {
      final items = await ApiService.fetchCart();
      setState(() {
        cartItems = items;
        isLoading = false;
        calculateTotalAmount(); // Calculate the total amount
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching cart: $e')),
      );
    }
  }

  /// Calculate the total amount in the cart
  void calculateTotalAmount() {
    totalAmount = cartItems.fold(0.0, (sum, item) {
      return sum + (item['quantity'] * item['price']);
    });
  }

  /// Remove an item from the cart
  Future<void> removeItem(String productId) async {
    try {
      await ApiService.removeFromCart(productId);
      fetchCart(); // Refresh cart after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing item: $e')),
      );
    }
  }

  /// Clear the cart
  Future<void> clearCart() async {
    try {
      await ApiService.clearCart();
      fetchCart(); // Refresh cart after clearing
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing cart: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: clearCart,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty."))
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final product = item['productId'];
                    return ListTile(
                      leading: const Icon(Icons.shopping_bag, color: Colors.pink),
                      title: Text(product['name'] ?? "Unknown Product"),
                      subtitle: Text(
                        "Quantity: ${item['quantity']} - ${item['price']} TND",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeItem(product['_id']),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Total: ${totalAmount.toStringAsFixed(2)} TND", // Format total amount
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderFormScreen(totalAmount: double.parse(totalAmount.toStringAsFixed(2))),
                  ),
                );
              },
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}
