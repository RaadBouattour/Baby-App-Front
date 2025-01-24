import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace this with actual user data
    final Map<String, String> user = {
      "name": "John Doe",
      "email": "john.doe@example.com",
      "address": "123 Street, City, Country"
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout logic
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.person, size: 40),
              title: Text(user['name'] ?? ""),
              subtitle: const Text('Name'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email, size: 40),
              title: Text(user['email'] ?? ""),
              subtitle: const Text('Email'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on, size: 40),
              title: Text(user['address'] ?? ""),
              subtitle: const Text('Address'),
            ),
          ],
        ),
      ),
    );
  }
}
