import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost:5000";

  /// Login function
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      print("DEBUG: Login response status: ${response.statusCode}");
      print("DEBUG: Login response body: ${response.body}");

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
      print("DEBUG: Error during login: $e");
      return {"error": "Connection error: $e"};
    }
  }



static Future<Map<String, dynamic>> placeOrder() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) throw Exception("User not authenticated");

  final response = await http.post(
    Uri.parse('$baseUrl/orders'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to place order');
  }
}



  /// Debug SharedPreferences
  static Future<void> debugSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print("DEBUG: Token: ${prefs.getString('token')}");
    print("DEBUG: User: ${prefs.getString('user')}");
  }


static Future<Map<String, dynamic>> placeOrderWithDetails(
    String fullName, String email, String phoneNumber, String address) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) throw Exception("User not authenticated");

  final response = await http.post(
    Uri.parse('$baseUrl/orders'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
    }),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to place order');
  }
}


// Fetch categories from the backend
  static Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  /// Fetch products for a specific category
  static Future<List<dynamic>> fetchCategoryProducts(String categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/products?category=$categoryId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load category products');
    }
  }

  static Future<List<dynamic>> fetchArticles() async {
    final response = await http.get(Uri.parse('$baseUrl/articles'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load articles');
    }
  }
static Future<List<dynamic>> fetchNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: {'Authorization': 'Bearer YOUR_TOKEN'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: {'Authorization': 'Bearer YOUR_TOKEN'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }


static Future<int> getUnreadNotificationsCount() async {
    final token = await getToken(); // Assuming a method to fetch the auth token
    final response = await http.get(
      Uri.parse("$baseUrl/notifications/unread-count"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['count'] as int;
    } else {
      throw Exception("Failed to fetch unread notifications count");
    }
  }

  static Future<String?> getToken() async {
    // Logic to get the user's auth token, e.g., from SharedPreferences
    return null;
  }
  /// Logout function
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    print("DEBUG: Logging out and removing token and user data.");
    await prefs.remove('token');
    await prefs.remove('user');
  }

  /// Signup function
  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );
      print("DEBUG: Signup response status: ${response.statusCode}");
      print("DEBUG: Signup response body: ${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {"success": true, "user": data['user']};
      } else {
        final error = jsonDecode(response.body);
        return {"error": error['message'] ?? "Signup failed"};
      }
    } catch (e) {
      print("DEBUG: Error during signup: $e");
      return {"error": "Connection error: $e"};
    }
  }

  /// Update user information
  static Future<Map<String, dynamic>> updateUserInfo(String name, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception("User not authenticated");

      final response = await http.put(
        Uri.parse("$baseUrl/users/update"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"name": name, "email": email}),
      );

      print("DEBUG: Update user info response status: ${response.statusCode}");
      print("DEBUG: Update user info response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString('user', jsonEncode(data['user']));
        return {"success": true};
      } else {
        final error = jsonDecode(response.body);
        return {"error": error['message'] ?? "Failed to update information"};
      }
    } catch (e) {
      print("DEBUG: Error updating user info: $e");
      return {"error": "Connection error: $e"};
    }
  }

  /// Fetch all products
  static Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products"));
      print("DEBUG: Fetch products response status: ${response.statusCode}");
      print("DEBUG: Fetch products response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> products = jsonDecode(response.body);
        return products;
      } else {
        throw Exception("Failed to load products. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("DEBUG: Error fetching products: $e");
      return [];
    }
  }




  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.containsKey('token');
    print("DEBUG: User is logged in: $isLoggedIn");
    return isLoggedIn;
  }

  /// Add item to cart
  static Future<void> addToCart(String productId, int quantity, double price) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')?.trim(); // Trim the token to remove whitespace

    if (token == null || token.isEmpty) {
      throw Exception("User not authenticated");
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart'),
        headers: {
          'Authorization': 'Bearer $token', // Add "Bearer" prefix
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
          'price': price,
        }),
      );

      if (response.statusCode != 200) {
        print("DEBUG: Add to Cart Error Response: ${response.body}");
        throw Exception("Failed to add product to cart");
      }
    } catch (e) {
      print("DEBUG: Error adding product to cart: $e");
      throw Exception("Error adding product to cart");
    }
  }





  /// Fetch user's cart
  static Future<List<dynamic>> fetchCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("User not authenticated");

      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final cart = jsonDecode(response.body);
        return cart['items'];
      } else if (response.statusCode == 404) {
        return []; // Empty cart
      } else {
        throw Exception('Failed to fetch cart');
      }
    } catch (e) {
      throw Exception('Error fetching cart: $e');
    }
  }

  /// Remove an item from the cart
  static Future<void> removeFromCart(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("User not authenticated");

      final response = await http.delete(
        Uri.parse('$baseUrl/cart/$productId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove item from cart');
      }
    } catch (e) {
      throw Exception('Error removing item from cart: $e');
    }
  }

  /// Clear the cart
  static Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("User not authenticated");

      final response = await http.delete(
        Uri.parse('$baseUrl/cart'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to clear cart');
      }
    } catch (e) {
      throw Exception('Error clearing cart: $e');
    }
  }


  /// Get logged-in user details
  static Future<Map<String, dynamic>> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    print("DEBUG: Logged-in user: $userString");

    if (userString != null) {
      return jsonDecode(userString);
    }
    return {};
  }
}
