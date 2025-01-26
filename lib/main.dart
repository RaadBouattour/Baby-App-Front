import 'package:baby_front/screens/cart_screen.dart';
import 'package:baby_front/screens/components/app_drawer.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/articles_screen.dart';
import 'screens/notifications_screen.dart'; // Import notifications screen
import 'screens/login_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baby Shop App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
      ),
      initialRoute: '/main',
      routes: {
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/cart': (context) => const CartScreen(),
        '/notifications': (context) => const NotificationsScreen(), // Add notifications route
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  int _cartItemCount = 0;
  int _notificationsCount = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const CategoriesScreen(),
    const ArticlesScreen(),
    const CartScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchCartItemCount();
    _fetchNotificationsCount();
  }

  /// Check if the user is logged in
  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await ApiService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });

    if (!_isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// Fetch the number of items in the cart
  Future<void> _fetchCartItemCount() async {
    try {
      final cart = await ApiService.fetchCart();
      setState(() {
        _cartItemCount = cart.length;
      });
    } catch (e) {
      print('Error fetching cart item count: $e');
    }
  }

  /// Fetch the number of unread notifications
  Future<void> _fetchNotificationsCount() async {
    try {
      final count = await ApiService.getUnreadNotificationsCount(); // API call for unread notifications
      setState(() {
        _notificationsCount = count;
      });
    } catch (e) {
      print('Error fetching notifications count: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 3) {
      // Refresh cart count when navigating to the cart screen
      _fetchCartItemCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello Mommy'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_notificationsCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_notificationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: _isLoggedIn ? const AppDrawer() : null, // Show drawer only if logged in
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          const BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Articles'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (_cartItemCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_cartItemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}
