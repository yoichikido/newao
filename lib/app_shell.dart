//module: app_shell.dart
import 'package:flutter/material.dart';
import 'navigation_menu.dart'; // Import the NavigationMenu module
import 'login_page.dart';
import 'push_notification_page.dart';
import 'text_editor_page.dart';
import 'messaging_page.dart';
import 'settings_page.dart';
import 'membership_page.dart';
import 'direct_video_page.dart';

class AppShell extends StatefulWidget {

  AppShell({Key? key}) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  bool _showAppBar = true;
  
  @override
  void initState() {
    super.initState();
    // If you need to do an initial check or setup, place it here.
  }
  void _updateAppBarVisibility(bool isVisible) {
    if (_showAppBar != isVisible) { // Add a check to prevent unnecessary setState calls
      setState(() {
        _showAppBar = isVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showAppBar ? AppBar(backgroundColor: Colors.amber, title: Text('AppShell 1')) : null,
      // appBar: AppBar(backgroundColor: Colors.amber,title: Text('AppShell'),),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          int sensitivity = 8; // Adjust this for more or less sensitivity
          if (details.delta.dy > sensitivity) {
            // Swipe down detected
            setState(() {
              _showAppBar = true;
            });
          } else if (details.delta.dy < -sensitivity) {
            // Swipe up detected
            setState(() {
              _showAppBar = false;
            });
          }
        },
        child: Navigator(
          key: navigatorKey,
          onGenerateRoute: (settings) {
            // // Hide the AppBar when navigating to sub-pages
            // _updateAppBarVisibility(settings.name == '/');
            // Instead of updating the app bar visibility immediately,
            // schedule it to happen after the build.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateAppBarVisibility(settings.name == '/');
            });
            switch (settings.name) {
              case '/login':
                return MaterialPageRoute(builder: (context) => const LoginPage());
              case '/':
                return MaterialPageRoute(builder: (context) => const LoginPage());
              case '/notifications':
                return MaterialPageRoute(builder: (context) => PushNotificationPage());
              case '/text_editor':
                return MaterialPageRoute(builder: (context) => const TextEditorPage());
              case '/messaging':
                return MaterialPageRoute(builder: (context) => MessagingPage());
              case '/settings':
                return MaterialPageRoute(builder: (context) => SettingsPage());
              case '/membership':
                return MaterialPageRoute(builder: (context) => MembershipPage());
              case '/direct_video':
                return MaterialPageRoute(builder: (context) => DirectVideoPage());
              default:
                return MaterialPageRoute(builder: (context) => const LoginPage()); // Default page
            }
          },
        ),
      ),
      drawer: NavigationMenu(navigatorKey: navigatorKey, updateAppBarVisibility: _updateAppBarVisibility,),
    );
  }
}