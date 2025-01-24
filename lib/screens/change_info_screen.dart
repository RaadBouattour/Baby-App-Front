import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChangeInfoScreen extends StatefulWidget {
  const ChangeInfoScreen({Key? key}) : super(key: key);

  @override
  State<ChangeInfoScreen> createState() => _ChangeInfoScreenState();
}

class _ChangeInfoScreenState extends State<ChangeInfoScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = await ApiService.getLoggedInUser();
    setState(() {
      _nameController.text = user['name'] ?? '';
      _emailController.text = user['email'] ?? '';
    });
  }

  Future<void> _updateInfo() async {
    setState(() {
      _isLoading = true;
    });

    final response = await ApiService.updateUserInfo(
      _nameController.text.trim(),
      _emailController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.containsKey('success')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Information updated successfully')),
      );
      Navigator.pop(context); // Return to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error'] ?? 'Failed to update information')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _updateInfo,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
