//module main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure this is imported
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'firebase_service.dart'; // Adjust according to your implementation
import 'app_state.dart';
import 'app_shell.dart';
import 'login_page.dart';
import 'stripe_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Removed for brevity: providers setup remains the same

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        Provider<FirebaseService>(create: (_) => FirebaseService()),
        Provider<StripeService>(create: (_) => StripeService()),
        StreamProvider<User?>.value(
          value: FirebaseService().authStateChanges(),
          initialData: null,),
        //2 Providers below for text chat messaging page
        // ChangeNotifierProvider(create: (context) => AppState()..fetchTextChatRooms()),
        // StreamProvider(create: (context) => context.read<AppState>().listenForMessages("specificRoomId"), initialData: []),
        StreamProvider<List<Map<String, dynamic>>>.value(
          value: FirebaseService().listenForMessages("specificRoomId"),
          initialData: [],
          catchError: (context, error) {
            print("Error fetching messages: $error");
            return [];
          }
        ),
      ],
      child: MaterialApp(
        home: Builder( // Added Builder to use context below
          builder: (BuildContext context) {
            // Access FirebaseService from the provider
            final firebaseService = Provider.of<FirebaseService>(context, listen: false);
            return StreamBuilder<User?>(
              stream: firebaseService.authStateChanges(),
              builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                    //  logic from NV30
                if (snapshot.connectionState == ConnectionState.active) {
                  if(snapshot.data !=null) {return AppShell();} else {return const LoginPage();}
                } else {return const CircularProgressIndicator();}

                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return const CircularProgressIndicator(); // Show loading indicator during wait
                // } else if (snapshot.hasError) {
                //   return Center(child: Text('Error: ${snapshot.error}')); // Error handling
                // } else if (snapshot.data == null) {
                //   return const LoginPage(); // User is not signed in, show login
                //   print('Login page from Main snapshot.data is null');
                // } else {
                //   return AppShell(); // User is signed in, show app shell
                // }
              },
            );
          },
        ),
      ),
    );
  }
}


// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   // Removed the direct instantiation of FirebaseService here
//   // It can be provided via Provider if used across multiple widgets/screens
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => AppState()),
//         Provider<FirebaseService>(create: (_) => FirebaseService()),
//       ],
//       child: MaterialApp(
//         // Instead of using onGenerateRoute at this level,
//         // directly decide which main widget to display based on auth state
//         home: StreamBuilder<User?>(
//           stream: FirebaseService().authStateChanges(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return CircularProgressIndicator(); // Show loading indicator during wait
//             } else if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}')); // Error handling
//             } else if (snapshot.data == null) {
//               return LoginPage(); // User is not signed in, show login
//             } else {
//               return AppShell(); // User is signed in, show app shell
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
