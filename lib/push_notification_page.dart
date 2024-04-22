import 'package:flutter/material.dart';
import 'app_state.dart'; // Adjust the import path based on your project structure
import 'package:provider/provider.dart';

class PushNotificationPage extends StatelessWidget {
  const PushNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppState appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.fetchNotifications(),  // Refresh notifications
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: appState.notifications.length,
        itemBuilder: (context, index) {
          var notification = appState.notifications[index];
          return ListTile(
            title: Text(notification['title'] ?? "No Title"),
            subtitle: Text(notification['body'] ?? "No Body"),
          );
        },
      ),
    );
  }
}

