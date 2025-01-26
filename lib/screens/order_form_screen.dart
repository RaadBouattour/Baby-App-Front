import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderFormScreen extends StatefulWidget {
  final double totalAmount;

  const OrderFormScreen({Key? key, required this.totalAmount}) : super(key: key);

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String email = '';
  String phoneNumber = '';
  String address = '';

  Future<void> submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    try {
      final response = await ApiService.placeOrderWithDetails(
        fullName,
        email,
        phoneNumber,
        address,
      );

      // Show success popup
      _showSuccessPopup(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }

  void _showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Order Placed Successfully!',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Thank you for your order. It has been successfully placed. You will receive updates about your order status soon!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
                Navigator.pop(context); // Navigate back to the cart/home screen
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Your Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your full name'
                    : null,
                onSaved: (value) => fullName = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) => email = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r"^\d{8}$").hasMatch(value)) {
                    return 'Phone number must be 8 digits';
                  }
                  return null;
                },
                onSaved: (value) => phoneNumber = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your address'
                    : null,
                onSaved: (value) => address = value!,
              ),
              const SizedBox(height: 20),
              Text(
                "Total: ${widget.totalAmount.toStringAsFixed(2)} TND",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitOrder,
                child: const Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
