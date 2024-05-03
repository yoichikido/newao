//module firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io'; // Import dart:io to check the platform
import 'package:shared_preferences/shared_preferences.dart'; //to save preferences locally
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/material.dart'; // for phone login
import 'package:get/get.dart'; // for phone login
import 'package:pin_code_fields/pin_code_fields.dart'; // for phone login
// import 'package:twitter_login/twitter_login.dart';
// import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
//import 'package:flutter_twitter_login/flutter_twitter_login.dart'; //does not support null safety

class FirebaseService {
  final FirebaseAuth _auth; // got rid of final and = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  // **** Need to do more securely in production ****
  // Create local secure storage for user twitter credentials
  // final twitterSecureStore = const FlutterSecureStorage();
  FirebaseService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    // required FirebaseAuth auth,
    // required FirebaseFirestore firestore,
    // required FirebaseStorage storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ??  FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;
  
// ---=== video methods from here===---


// ---=== video methods to here===---

// --===@@@@ athentication stuff below @@@@===--
//signInWithLastUsedMethod used in MyApp, not in MyStreambuilderApp
  Future<User?> signInWithLastUsedMethod(
      {String? email, String? password}) async {
    // print('in signInWithLastUse`dMethod()stack trace:${StackTrace.current}');
    String? lastUsedAuthMethod = await getLastUsedAuthMethod();
    if (lastUsedAuthMethod == null) {
      return null;
    }
    switch (lastUsedAuthMethod) {
      case 'google':
        return signInWithGoogle();
      // case 'facebook':
      //   return signInWithFacebook();
      // case 'twitter':
      //   return signInWithTwitter();
      case 'apple':
        return signInWithApple();
      case 'emailAndPassword':
        //Retrieve email and password from local storage
        if (email != null && password != null) {
          return signInWithEmailAndPassword(email, password);
        }
        return null;
      //case 'phone':
      // Retrieve phone number from local storage
      //  return signInWithPhone(phoneNumber);
      case 'anonymous':
        return signInAnonymously();
      default:
        return null;
    }
  }
  Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      // print('dave<<User signed in anonymously UID: ${userCredential.user!.uid}');
      return userCredential.user; // return User object
    } catch (e) {
      // print('Error signing in anonymously: $e');
      return null;
    }
  }
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      return user;
    } catch (e) {
      // print('____ Error signing in with Google >>>> : $e');
      return null;
    }
  }
  Future<User?> signInWithApple() async {
    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: Platform.isAndroid
            ? WebAuthenticationOptions(
                clientId: 'tv.kidfam.nv30.apple-sign-in', // service ID from developer consuol
                redirectUri: Uri.parse(
                    'https://nov-end-copy.firebaseapp.com/__/auth/handler'), // Your redirect URI "Return URL"
              )
            : null,
      );
      
      // Create an OAuthCredential for signing in
      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      return user;
    } catch (e) {
      // print('____ Error signing in with Apple >>>> : $e');
      return null;
    }
  }
  Future<User?> signInWithPhone(
      String phoneNumber, BuildContext context) async {
    User? user;
    _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        user = authResult.user;
      },
      verificationFailed: (FirebaseAuthException e) {
        // print('Failed to Verify Phone Number: ${e.message}');
      },
      codeSent: (String verificationId, [int? forceResendingToken]) async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Enter SMS Code"),
            content: PinCodeTextField(
              appContext: context,
              length: 4,
              onChanged: (value) {},
              onCompleted: (value) async {
                PhoneAuthCredential phoneAuthCredential =
                    PhoneAuthProvider.credential(
                  verificationId: verificationId,
                  smsCode: value,
                );
                final UserCredential authResult =
                    await _auth.signInWithCredential(phoneAuthCredential);
                user = authResult.user;
                Get.back();
              },
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // print('Auto Retrieval Time Out');
      },
    );
    return user;
  }
  Future<User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      // print('Attempting to resister user $email with pw $password');
      //// print('pw: $password')
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      // print("error registering user: $e");
      return null;
    }
  }
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      // print('Error signing in with email and password: $e');
      return null;
    }
  }
  Future<User?> getCurrentUser() async => _auth.currentUser;
  Future<void> signOut() async {
    print('signing out with FirebaseService.signOut');
    await _auth.signOut();
  }
  // --===@@@@ athentication stuff above @@@@===--

//todo>> add a saveTextToFirestoreByName
//
  Future<bool> saveTextToFirestore(String textContent, String userId) async {
    // print('================ Saving text to Firestore ______');
    // print('>>> Text content: $textContent');
    // print('>>> User ID: $userId');
    // print('================ ================================');
    try {
      await _firestore.collection('users').doc(userId).collection('texts').add({
        'content': textContent,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // print('Text >>> save !!!  SUCCESS  !!!  /////////// ');
      return true;
    } catch (e) {
      // print('Error-_ _ _ _ _ NO! NO! NO! while saving text: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getTextsFromFirestore(
      String userId) async {
    List<Map<String, dynamic>> texts = [];
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('texts')
          .orderBy('timestamp', descending: true)
          .get();

      for (var doc in snapshot.docs) {
        texts.add(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      // print('Error while fetching texts: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Error while fetching texts from Firestore: $e'),
      //   ),
      // );

    }
    return texts;
  }

  Future<String?> getLastSavedText(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('texts')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      return (querySnapshot.docs.first.data()
          as Map<String, dynamic>)['content'] as String?;
    } catch (e) {
      // print('Error while retrieving last saved text: $e');
      return null;
    }
  } //getLastSavedText

  // To save preferences locally to allow same login as previous
  Future<void> saveLastUsedAuthMethod(String authMethod) async {
    // print('>>   >>   >>   Saving auth method $authMethod');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_used_auth_method', authMethod);
  }

  Future<String?> getLastUsedAuthMethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print(
        // '>>__ Got last auth method ${prefs.getString('last_used_auth_method')}');
    return prefs.getString('last_used_auth_method');
  }

  Future<void> removeLastUsedAuthMethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print(
        // '>>__ removing last auth method ${prefs.getString('last_used_auth_method')}');
    await prefs.remove('last_used_auth_method');
  }

//ToTest below
  Future<void> incrementUserDeviceCountByAdding(String userId) async {
    // print(
        // ">>> >>> ___ In firebase_service incrementUserDeviceCountByAdding <<<");

    DocumentReference userRef = _firestore.collection('users').doc(userId);
    DocumentSnapshot snapshot = await userRef.get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data()
          as Map<String, dynamic>?; // Cast data to the correct type
      int previousDeviceCount = data?['devicesConnectedCount'] ?? 0;
      int newUserDeviceCount = previousDeviceCount + 1;

      return userRef.update({
        'devicesConnectedCount': newUserDeviceCount,
      }).catchError((error) {
        throw error;
      });
    } else {
      return userRef.set({
        'devicesConnectedCount': 1,
      }).catchError((error) {
        throw error;
      });
    }
  }

//above replaces below. Now not using .increment
  Future<void> incrementUserDeviceCount(String userId) async {
    // print(">>> >>> ___ In firebase_service incrementUserDeviceCount <<<");
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(userId).get();
    if (snapshot.exists) {
      // The document exists, update the 'deviceCount' field with increment
      return _firestore.collection('users').doc(userId).update({
        'deviceCount': FieldValue.increment(1000),
      }).catchError((error) {
        throw error;
      });
    } else {
      // The document does not exist, create it with 'deviceCount' set to 1
      return _firestore.collection('users').doc(userId).set({
        'deviceCount': 1,
      }).catchError((error) {
        throw error;
      });
    }
  }

  Future<void> incrementUserdeviceCountNew(String userId) async {
    // print(">>> >>> ___ In firebase_service incrementUserdeviceCountNew <<<");
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(userId).get();
    if (snapshot.exists) {
      // The document exists, update the 'deviceCountNew' field with increment
      return _firestore.collection('users').doc(userId).update({
        'deviceCountNew': FieldValue.increment(1000),
      }).catchError((error) {
        throw error;
      });
    } else {
      // The document does not exist, create it with 'deviceCountNew' set to 1
      return _firestore.collection('users').doc(userId).set({
        'deviceCountNew': 1,
      }).catchError((error) {
        throw error;
      });
    }
  }

  Future<void> decrementUserDeviceCount(String userId) {
    return _firestore.collection('users').doc(userId).update({
      'devicesConnectedCount': FieldValue.increment(-1),
    });
  }

  Stream<User?> authStateChanges() {
    return _auth
        .authStateChanges(); //returns a Stream that is updated whenever the user's authentication state changes
  }

// ---=== text chat methods from here===---
  Stream<List<Map<String, dynamic>>> listTextChatRooms() {
    return _firestore.collection('textChatRooms').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'textChatRoomId': doc.id,
          'roomName': doc['roomName'],
          'participantCount': doc['participants'].length,
          'activeParticipants': doc['participants'].where((p) => p['active']).length,
        };
      }).toList();
    });
  }

  Future<void> joinTextChatRoom(String textChatRoomId, String userId) async {
    DocumentReference roomRef = _firestore.collection('textChatRooms').doc(textChatRoomId);
    await roomRef.collection('participants').doc(userId).set({
      'id': userId,
      'approvedStatus': false,
      'active': true,
      'requestingEntry': true,
      'rightToApprove': false,
    });
    sendMessage(textChatRoomId, "$userId wants to join", userId);
  }

  Future<void> leaveTextChatRoom(String textChatRoomId, String userId) async {
    DocumentReference participantRef = _firestore.collection('textChatRooms').doc(textChatRoomId).collection('participants').doc(userId);
    await participantRef.delete();
  }


  Future<void> sendMessage(String textChatRoomId, String content, String senderId, {String? repliedToId}) async {
    await _firestore.collection('textChatRooms').doc(textChatRoomId).collection('messages').add({
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'senderId': senderId,
      'repliedToId': repliedToId ?? '',
    });
  }

  Stream<List<Map<String, dynamic>>> listenForMessages(String textChatRoomId) {
    return _firestore.collection('textChatRooms').doc(textChatRoomId).collection('messages').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  Future<void> pauseMessages(String textChatRoomId, String userId) async {
    sendMessage(textChatRoomId, "$userId has paused messages", userId);
  }

  Future<void> unpauseMessages(String textChatRoomId, String userId) async {
    sendMessage(textChatRoomId, "$userId has unpaused messages", userId);
  }

  Future<void> approveParticipant(String textChatRoomId, String participantId, bool approve, bool rightToApprove) async {
    DocumentReference participantRef = _firestore.collection('textChatRooms').doc(textChatRoomId).collection('participants').doc(participantId);
    if (approve) {
      await participantRef.update({
        'approvedStatus': true,
        'rightToApprove': rightToApprove,
      });
    } else {
      await participantRef.delete();
    }
  }

  Future<void> createTextChatRoom(String roomName, String userId) async {
    DocumentReference newRoomRef = await _firestore.collection('textChatRooms').add({
      'roomName': roomName,
      'creatorId': userId,
    });
    await joinTextChatRoom(newRoomRef.id, userId);
    sendMessage(newRoomRef.id, "$userId has created the room '$roomName' and has left this room", userId);
  }

  Future<List<Map<String, dynamic>>> pullOlderMessages(String textChatRoomId) async {
    QuerySnapshot snapshot = await _firestore.collection('textChatRooms').doc(textChatRoomId).collection('messages')
      .orderBy('timestamp', descending: true).limit(5).get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

// ---=== text chat methods to here ===---
// For membership data
Future<bool> saveMemberData(String name, String email, String userId) async {
  try {
    await FirebaseFirestore.instance.collection('members').doc(userId).set({
      'name': name,
      'email': email,
      'registered': Timestamp.now(),
    });
    return true; // Successfully saved
  } catch (e) {
    print('Error saving member data: $e');
    return false; // Failed to save
  }
}
// General Advice (GPT4)
// Asynchronous Methods: When you don't need to wait for a method's result immediately (like firing and forgetting a logging operation), you might consider not awaiting it, depending on your specific use case.
// Return Information: Methods that perform critical operations (like data saving) often benefit from returning more information than just void or a simple type, as this can help with debugging and user feedback.


//for listening to changes in devicesConnectedCount
//is the below even used?
  // Stream<DocumentSnapshot?> getUserDocumentStream(String userId) {
  //   return _firestore.collection('users').doc(userId).snapshots();
  // }
} //FirebaseService
