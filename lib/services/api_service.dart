import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost:5000"; // Replace with your backend base URL

  /// Login function
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));
        return {"success": true, "user": data['user']};
      } else {
        final error = jsonDecode(response.body);
        return {"error": error['message'] ?? "Invalid credentials"};
      }
    } catch (e) {
      return {"error": "Connection error: $e"};
    }
  }

  /// Signup function
  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {"success": true, "user": data['user']};
      } else {
        final error = jsonDecode(response.body);
        return {"error": error['message'] ?? "Signup failed"};
      }
    } catch (e) {
      return {"error": "Connection error: $e"};
    }
  }

  /// Fetch all products   Teee5dem jwha Behy
  static Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products"));
      if (response.statusCode == 200) {
        // Decode the JSON and return the list directly
        final List<dynamic> products = jsonDecode(response.body);
        return products;
      } else {
        throw Exception("Failed to load products. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in fetchProducts: $e");
      return [];
    }
  }



  /// Fetch product details by ID
  static Future<Map<String, dynamic>> fetchProductById(String id) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products/$id"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Product not found"};
      }
    } catch (e) {
      return {"error": "Connection error: $e"};
    }
  }



  // Update user his info
  static Future<Map<String, dynamic>> updateUserInfo(String name, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return {"error": "User not authenticated"};

      final response = await http.put(
        Uri.parse("$baseUrl/user/update"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"name": name, "email": email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString('user', jsonEncode(data['user']));
        return {"success": true};
      } else {
        final error = jsonDecode(response.body);
        return {"error": error['message'] ?? "Failed to update information"};
      }
    } catch (e) {
      return {"error": "Connection error: $e"};
    }
  }



  /// Add product to cart
  static Future<Map<String, dynamic>> addToCart(String productId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return {"error": "User not authenticated"};

      final response = await http.post(
        Uri.parse("$baseUrl/cart"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"productId": productId, "quantity": quantity}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return {"error": error['message'] ?? "Unable to add to cart"};
      }
    } catch (e) {
      return {"error": "Connection error: $e"};
    }
  }

  /// Fetch cart items
  static Future<List<dynamic>> fetchCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return [];

      final response = await http.get(
        Uri.parse("$baseUrl/cart"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['items'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Place an order
  static Future<Map<String, dynamic>> placeOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return {"error": "User not authenticated"};

      final response = await http.post(
        Uri.parse("$baseUrl/orders"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return {"error": error['message'] ?? "Unable to place order"};
      }
    } catch (e) {
      return {"error": "Connection error: $e"};
    }
  }

  /// Fetch articles
  static Future<List<dynamic>> fetchArticles() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/articles"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['articles'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Fetch categories
  static Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/categories"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['categories'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Search products by name
  static Future<List<dynamic>> searchProducts(String query) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products/search?q=$query"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['products'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  /// Get logged-in user details
  static Future<Map<String, dynamic>> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      return jsonDecode(userString);
    }
    return {};
  }
}
