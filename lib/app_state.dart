//module: app_state.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import Firestore if you plan to use it for tracking resources or other states
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AppState with ChangeNotifier {
  // Firebase Auth instance for user authentication state
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  // List<RemoteMessage> _notifications = [];
  List<Map<String, dynamic>> _notifications = [];  // Change to store simple maps

  // Text editing contents
  String _currentText = '';

  // AppState constructor
  AppState() {
    _listenToAuthState();
    _initFirebaseMessaging();
    // Additional initialization as needed
  }

  // List<RemoteMessage> get notifications => _notifications;
  List<Map<String, dynamic>> get notifications => _notifications;

  // User authentication state ***!!!defining 2x is this necessary
  User? get user => _user;
  
  //use uid and not user when only uid is necessary
  String? get uid => _user?.uid;

  // Text editing content
  String get currentText => _currentText;

  // Listen to Firebase Auth state changes
  void _listenToAuthState() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        fetchNotifications(); // Call fetch notifications when user is authenticated
      }
      notifyListeners(); // Notify listeners about change in auth state
    });
  }

  void _initFirebaseMessaging() {
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  // void _handleMessage(RemoteMessage message) {
  //   _notifications.add(message);
  //   notifyListeners();
  // }
  void _handleMessage(RemoteMessage message) {
      // Assuming you're only interested in the notification part of the message
      if (message.notification != null) {
          Map<String, dynamic> notificationDetails = {
              'title': message.notification!.title,
              'body': message.notification!.body
          };
          _notifications.add(notificationDetails);
          notifyListeners();
      }
  }

  // void _fetchNotifications() async {
  //   if (_user?.uid == null) return;

  //   final QuerySnapshot result = await FirebaseFirestore.instance
  //       .collection('notifications')
  //       .where('userId', isEqualTo: _user?.uid)
  //       .get();

  //   List<RemoteMessage> fetchedNotifications = result.docs
  //       .map((doc) => RemoteMessage(notification: Notification(
  //         title: doc['title'],
  //         body: doc['body']
  //       )))
  //       .toList();

  //   _notifications = fetchedNotifications;
  //   notifyListeners();
  // }
  // Update text content
  void fetchNotifications() async {
    if (_user?.uid == null) return;

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: _user?.uid)
        .get();

    _notifications = result.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .map((data) => {
          'title': data['title'] ?? 'No Title',
          'body': data['body'] ?? 'No Body'
        }).toList();

    notifyListeners();
  }
  // void fetchNotifications() async {
  //   if (_user?.uid == null) return;
  //   final QuerySnapshot result = await FirebaseFirestore.instance
  //       .collection('notifications')
  //       .where('userId', isEqualTo: _user?.uid)
  //       .get();
  //   List<Map<String, dynamic>> fetchedNotifications = result.docs
  //       .map((doc) => {
  //         'title': doc.data()['title'] as String? ?? 'No Title',
  //         'body': doc.data()['body'] as String? ?? 'No Body'
  //       })
  //       .toList();
  //   _notifications = fetchedNotifications;
  //   notifyListeners();
  // }

  void updateText(String newText) {
    _currentText = newText;
    notifyListeners(); // Notify listeners about change in text content
  }

  // Example methods to handle sign-in and sign-out
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // signInWithEmailAndPassword automatically triggers _listenToAuthState
    } catch (e) {
      print("Error signing in: $e");
      // Handle error
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // signOut automatically triggers _listenToAuthState
  }

  // Optionally, integrate Firestore for tracking resources or other app-wide states
  // Example: Tracking resource availability
  // void checkResourceAvailability() {
  //   FirebaseFirestore.instance.collection('resources').doc('resourceId').snapshots().listen((snapshot) {
  //     bool isAvailable = snapshot.data()?['isAvailable'] ?? false;
  //     // Update AppState with this information as needed and call notifyListeners()
  //   });
  // }

  // Add other methods as needed based on your app's functionality
}

// As app evolves may be helpful to:
// Segment AppState: For complex apps, consider dividing AppState into smaller, focused state management classes (e.g., AuthState, TextState, ResourceState) to maintain readability and manageability.
// Enhance error handling: Particularly around Firebase Auth operations, to improve user experience.
// Expand Firestore usage: Depending on your app’s requirements, integrating Firestore for real-time data handling could significantly enhance its functionality.

