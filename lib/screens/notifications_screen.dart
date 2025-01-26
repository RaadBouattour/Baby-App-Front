import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  /// Fetch notifications from backend
  Future<void> fetchNotifications() async {
    try {
      final fetchedNotifications = await ApiService.fetchNotifications();
      setState(() {
        notifications = fetchedNotifications;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching notifications: $e')),
      );
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await ApiService.markNotificationAsRead(notificationId);
      fetchNotifications(); // Refresh notifications
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking notification as read: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text('No notifications available.'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Card(
                      child: ListTile(
                        title: Text(notification['title']),
                        subtitle: Text(notification['message']),
                        trailing: !notification['isRead']
                            ? ElevatedButton(
                                onPressed: () => markAsRead(notification['_id']),
                                child: const Text('Mark as Read'),
                              )
                            : const Icon(Icons.check, color: Colors.green),
                      ),
                    );
                  },
                ),
    );
  }
}
