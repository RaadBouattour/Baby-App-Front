import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: ListView.builder(
        itemCount: 3, // Example cart items
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.pink),
            title: const Text('Product Name'),
            subtitle: const Text('Quantity: 1 - \$10.00'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: () {
                    // Decrease quantity
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: () {
                    // Increase quantity
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Navigate to order form
          },
          child: const Text('Commander'),
        ),
      ),
    );
  }
}
