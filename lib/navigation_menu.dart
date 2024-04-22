//module: navigation_menu.dart
import 'package:flutter/material.dart';

class NavigationMenu extends StatelessWidget {
  GlobalKey<NavigatorState> navigatorKey;
  final Function(bool) updateAppBarVisibility;

  NavigationMenu({Key? key, required this.navigatorKey, required this.updateAppBarVisibility}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("!in Nav menu build widget:)");
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(child: Text('Navigation Menu')),
          _createDrawerItem(
            context: context,
            icon: Icons.login,
            text: 'Login',
            routeName: '/login',
          ),
          _createDrawerItem(
            context: context,
            icon: Icons.notifications,
            text: 'Push Notifications',
            routeName: '/notifications',
          ),
          _createDrawerItem(
            context: context,
            icon: Icons.edit,
            text: 'Text Editor',
            routeName: '/text_editor',
          ),
          _createDrawerItem(
            context: context,
            icon: Icons.message,
            text: 'Messaging',
            routeName: '/messaging',
          ),
          _createDrawerItem(
            context: context,
            icon: Icons.settings,
            text: 'Settings',
            routeName: '/settings',
          ),
          _createDrawerItem(
            context: context,
            icon: Icons.card_membership,
            text: 'Membership',
            routeName: '/membership',
          ),
          _createDrawerItem(
            context: context,
            icon: Icons.video_call,
            text: 'Direct Video',
            routeName: '/direct_video',
          ),
          // Repeat for other drawer items
        ],
      ),
    );
  }

  Widget _createDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required String routeName,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        Navigator.of(context).pop(); // Close the drawer
        updateAppBarVisibility(false); // Hide the AppBar on the main screen
        navigatorKey.currentState?.pushNamed(routeName); // Use the navigator key
      },
    );
  }
}