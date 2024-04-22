// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'firebase_service.dart';
// import 'main.dart'; // Import MyHomePage
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class LoginPage extends StatefulWidget {
//   final FirebaseService firebaseService;
//   final String uid;

//   const LoginPage(
//       {super.key, required this.firebaseService, required this.uid});
//   @override
//   _LoginPageState createState() =>
//       _LoginPageState(firebaseService: firebaseService, uid: uid ?? '');
// }

// class _LoginPageState extends State<LoginPage> {
//   final FirebaseService firebaseService;
//   final String uid;
//   // TextEditingController objects to catch inputted email and password
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   @override
//   void dispose() {
//     //clean up controllers when widget diosposed
//     _emailController.dispose();
//     _passwordController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   _LoginPageState({required this.firebaseService, required this.uid});

//   @override
//   Future<void> _signInAnonymously() async {
//     try {
//       User? user = await widget.firebaseService.signInAnonymously();
//       if (user != null) {
//         print("dave>>Anon sign in success user:${user.uid}");
//         await widget.firebaseService
//             .saveLastUsedAuthMethod('anonymous'); //save locally
//         // Assuming AppShell is now the main scaffold for app
//         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AppShell()));

//       } else {
//         print("Sign in failed!");
//       }
//     } catch (e) {
//       print("Error signing in signInAnonymously: $e");
//     }
//   }

//   Future<User?> _signInWithGoogle() async {
//     try {
//       User? user = await widget.firebaseService.signInWithGoogle();
//       if (user != null) {
//         print("Sign in with Google successful!");
//         await widget.firebaseService
//             .saveLastUsedAuthMethod('google'); //save locally
//         return user;
//       } else {
//         print("Sign in failed!");
//       }
//     } catch (e) {
//       print("Error signing in with Google: $e");
//     }
//     return null;
//   }

//   Future<User?> _signInWithApple() async {
//     try {
//       User? user = await widget.firebaseService.signInWithApple();
//       if (user != null) {
//         print("Sign in with Apple successful!");
//         await widget.firebaseService
//             .saveLastUsedAuthMethod('apple'); // Save locally
//         return user;
//       } else {
//         print("Sign in failed!");
//       }
//     } catch (e) {
//       print("Error signing in with Apple: $e");
//     }
//     return null;
//   }

//   Future<void> _registerWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       User? user = await widget.firebaseService
//           .registerWithEmailAndPassword(email, password);
//       if (user != null) {
//         print("dave>>succes reg w email pw user:${user.uid}");
//         await widget.firebaseService.saveLastUsedAuthMethod('emailAndPassword');
//       } else {
//         print("reg with em and pw fail");
//       }
//     } catch (e) {
//       print("error reg with email and pw");
//     }
//   }

//   @override
//   Future<User?> _signInWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       User? user = await widget.firebaseService
//           .signInWithEmailAndPassword(email, password);
//       if (user != null) {
//         print("dave>>succes email signin user:${user.uid}");
//         await widget.firebaseService.saveLastUsedAuthMethod('emailAndPassword');
//         return user;
//       } else {
//         print("**** signin with em and pw faile");
//       }
//     } catch (e) {
//       print("error sign-in with email and pw");
//     }
//     return null;
//   }

//   void _showEmailPasswordLoginDialog() {
//     TextEditingController emailController = TextEditingController();
//     TextEditingController passwordController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Email & Password Login'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: [
//                 TextField(
//                   controller: emailController,
//                   decoration: const InputDecoration(hintText: "Email"),
//                 ),
//                 TextField(
//                   controller: passwordController,
//                   decoration: const InputDecoration(hintText: "Password"),
//                   obscureText: true,
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Register'),
//               onPressed: () {
//                 String email = emailController.text;
//                 String password = passwordController.text;
//                 _registerWithEmailAndPassword(email, password);
//                 print(emailController.text);
//                 print(passwordController.text);
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('CANCEL'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('LOGIN'),
//               onPressed: () async {
//                 String email = emailController.text;
//                 String password = passwordController.text;
//                 //User? user = null; //temp
//                 User? user = await _signInWithEmailAndPassword(email, password);
//                 if (user != null) {
//                   // Fetch the last saved text
//                   //String? lastText = '';
//                   String? lastText =
//                       await widget.firebaseService.getLastSavedText(user.uid);
//                   // Navigate to the main screen with the fetched text
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MyHomePage(
//                         // moreThanOneDeviceConnected: false,
//                         firebaseService: widget.firebaseService,
//                         uid: user.uid,
//                         lastText: lastText,
//                       ),
//                     ),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Login attempt with email and PW failed.'),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Login'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'Sign-in methods',
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),            
//             _verticalSpace(),
//             _verticalSpace(),
//             ElevatedButton.icon(
//               onPressed: () {
//                 widget.firebaseService
//                     .signInAnonymously()
//                     .then((User? user) async {
//                   if (user != null) {
//                     String? lastText =
//                         await widget.firebaseService.getLastSavedText(user.uid);
//                     // After signin, go to the HomePage
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => MyHomePage(
//                           // moreThanOneDeviceConnected: false,
//                           firebaseService: widget.firebaseService,
//                           uid: user.uid,
//                           lastText: lastText,
//                         ),
//                       ),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Anonymous login failed'),
//                       ),
//                     );
//                   }
//                 }).catchError((error) {
//                   print('Error signing in anonymously: $error');
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Anonymous login failed'),
//                     ),
//                   );
//                 });
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey,
//                 textStyle: const TextStyle(fontSize: 18), // Larger text size
//                 padding: const EdgeInsets.all(15), // Increased padding for larger touch area
//               ),
//               icon:
//                   const Icon(FontAwesomeIcons.circleUser, color: Colors.white),
//               label: const Text('Sign in anonymously'),
//             ),
//             _verticalSpace(), // Increased vertical space between buttons
           
//             _buildSignInButton(
//               onPressed: _showEmailPasswordLoginDialog,
//               iconData: FontAwesomeIcons.envelope,
//               label: 'Sign in with Email',
//               backgroundColor: Colors.blue,
//             ),
//             _verticalSpace(), //vertical space between button >on web
//             ElevatedButton.icon(
//               // Google signin button
//               onPressed: () async {
//                 User? user = await _signInWithGoogle();
//                 if (user != null) {
//                   // Fetch the last saved text
//                   String? lastText =
//                       await widget.firebaseService.getLastSavedText(user.uid);
//                   // Navigate to the main screen with the fetched text
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MyHomePage(
//                         // moreThanOneDeviceConnected: false,
//                         firebaseService: widget.firebaseService,
//                         uid: user.uid,
//                         lastText: lastText,
//                       ),
//                     ),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Google login failed'),
//                     ),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF4285F4),
//                 textStyle: const TextStyle(fontSize: 18), // Larger text size
//                 padding: const EdgeInsets.all(15), // Increased padding for larger touch area
//               ), // Google's blue color in RGB
//               icon: const Icon(FontAwesomeIcons.google, color: Colors.white),
//               label: const Text('Sign in with Google',
//                   style: TextStyle(color: Colors.white)),
//             ),
//             _verticalSpace(), //vertical space between button >on web
//             ElevatedButton.icon(
//               // Apple signin button
//               onPressed: () async {
//                 User? user = await _signInWithApple(); // Call your Apple sign-in method
//                 if (user != null) {
//                   // Fetch the last saved text
//                   String? lastText =
//                       await widget.firebaseService.getLastSavedText(user.uid);
//                   // Navigate to the main screen with the fetched text
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MyHomePage(
//                         firebaseService: widget.firebaseService,
//                         uid: user.uid,
//                         lastText: lastText,
//                       ),
//                     ),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Apple login failed'),
//                     ),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black, // Black background for contrast
//                 textStyle: const TextStyle(fontSize: 18), // Larger text size
//                 padding: const EdgeInsets.all(15), // Increased padding for larger touch area
//               ),
//               icon: const Icon(Icons.apple, color: Colors.white), // Apple icon in white
//               label: const Text('Sign in with Apple',
//                   style: TextStyle(color: Colors.white)),
//             ),
//             _verticalSpace(), //vertical space between button >on web
//             _buildSignInButton(
//               onPressed: SystemNavigator.pop,
//               iconData: Icons.exit_to_app,
//               label: 'Exit',
//               backgroundColor: Colors.red,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSignInButton({
//     required VoidCallback onPressed,
//     required IconData iconData,
//     required String label,
//     required Color backgroundColor,
//   }) {
//     return ElevatedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(iconData, color: Colors.white, size: 30), // Larger icon
//       label: Text(
//         label,
//         style: const TextStyle(fontSize: 20, color: Colors.white), // Larger text size
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: backgroundColor,
//         padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18), // Increased padding for larger touch area
//       ),
//     );
//   }

//   Widget _verticalSpace() => const SizedBox(height: 18); // Increased vertical space between buttons
// }
