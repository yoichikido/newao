// login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'app_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late FirebaseService firebaseService;//get in Provider.of in didChangeDependencies()
  // TextEditingController objects to catch inputted email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  @override
  void initState() {//now only here for convention, and future modifications
    super.initState();
    // Since initState does not have context, we defer the assignment to didChangeDependencies
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe to call Provider.of here because context is generically available in didChangeDependencies
    firebaseService = Provider.of<FirebaseService>(context, listen: false);
  }
  @override
  void dispose() {
    //clean up controllers when widget diosposed
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  // do not need the following constructor dependency injection as using Provider now
  //_LoginPageState({required this.firebaseService});// got rid of , required this.uid
  Future<void> _signInAnonymously() async {
    try {
      await firebaseService.signInAnonymously();
      await firebaseService
            .saveLastUsedAuthMethod('anonymous'); //save locally--this may not be necessary as firebase/flutter work together to maintain login state between app closes without this
      print("! :) SSSuccess signing in signInAnonymously 1");
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AppShell()));
    } catch (e) {
      print("Error signing in signInAnonymously: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anonymous login failed'),
        ),
      );
    }
  }
  Future<void> _signInAnonymously2() async {
    try {
      await firebaseService.signInAnonymously();
      await firebaseService
            .saveLastUsedAuthMethod('anonymous'); //save locally--this may not be necessary as firebase/flutter work together to maintain login state between app closes without this
      print("! :) SSSuccess signing in signInAnonymously 2");
      Navigator.of(context).pop(); // Close 
      Navigator.of(context).pushNamed('/settings');

      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MyApp()));
    } catch (e) {
      print("Error signing in signInAnonymously 2: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anonymous login failed'),
        ),
      );
    }
  }
  Future<User?> _signInWithGoogle() async {
    try {
      await firebaseService.signInWithGoogle();
      await firebaseService
            .saveLastUsedAuthMethod('google'); //save locally
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AppShell()));
    } catch (e) {
      // print("Error signing in with Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google login failed'),
        ),
      );
    }
    return null;
  }
  Future<User?> _signInWithApple() async {
    try {
      await firebaseService.signInWithApple();
      await firebaseService
            .saveLastUsedAuthMethod('apple'); // Save locally
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AppShell()));
    } catch (e) {
      // print("Error signing in with Apple: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apple login failed'),
        ),
      );
    }
    return null;
  }
  Future<void> _registerWithEmailAndPassword(
      String email, String password) async {
    try {
      await firebaseService
          .registerWithEmailAndPassword(email, password);
    } catch (e) {
      // print("error reg with email and pw");
    }
  }
  Future<User?> _signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await firebaseService
          .signInWithEmailAndPassword(email, password);
      await firebaseService.saveLastUsedAuthMethod('emailAndPassword');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AppShell()));
    } catch (e) {
      // print("error sign-in with email and pw");
    }
    return null;
  }
  void _showEmailPasswordLoginDialog() {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email & Password Login'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(hintText: "Email"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(hintText: "Password"),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Register'),
              onPressed: () {
                String email = emailController.text;
                String password = passwordController.text;
                _registerWithEmailAndPassword(email, password);
                // print(emailController.text);
                // print(passwordController.text);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('LOGIN'),
              onPressed: () async {
                String email = emailController.text;
                String password = passwordController.text;
                //User? user = null; //temp
                await _signInWithEmailAndPassword(email, password);
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AppShell()));              
              }
            ),
          ],
        );
      },
    );
  }
  Widget _buildSignInButton({
    required VoidCallback onPressed,
    required IconData iconData,
    required String label,
    required Color backgroundColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(iconData, color: Colors.white, size: 30), // Larger icon
      label: Text(
        label,
        style: const TextStyle(fontSize: 20, color: Colors.white), // Larger text size
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18), // Increased padding for larger touch area
      ),
    );
  }
  Widget _verticalSpace() => const SizedBox(height: 18); // Increased vertical space between buttons
  @override
  Widget build(BuildContext context) {
    // accessing FirebaseService using Provider and can now pass to other methods
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Login'),),
      // drawer: , ???
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Sign-in methods',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),            
            _verticalSpace(),
            _verticalSpace(),
            ElevatedButton.icon(
              onPressed: () async {
                await _signInAnonymously();
                // firebaseService.signInAnonymously()
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                textStyle: const TextStyle(fontSize: 18), // Larger text size
                padding: const EdgeInsets.all(15), // Increased padding for larger touch area
              ),
              icon:
                  const Icon(FontAwesomeIcons.circleUser, color: Colors.white),
              label: const Text('Sign in anonymously'),
            ),
            _verticalSpace(), // Increased vertical space between buttons
            ElevatedButton.icon(
              onPressed: () async {
                await _signInAnonymously2();
                // firebaseService.signInAnonymously()
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                textStyle: const TextStyle(fontSize: 18), // Larger text size
                padding: const EdgeInsets.all(15), // Increased padding for larger touch area
              ),
              icon:
                  const Icon(FontAwesomeIcons.circleUser, color: Colors.white),
              label: const Text('Sign in anonymously to MyApp'),
            ),
            _verticalSpace(), // Increased vertical space between buttons
            _buildSignInButton(
              onPressed: _showEmailPasswordLoginDialog,
              iconData: FontAwesomeIcons.envelope,
              label: 'Sign in with Email',
              backgroundColor: Colors.blue,
            ),
            _verticalSpace(), //vertical space between button >on web
            ElevatedButton.icon(
              // Google signin button
              onPressed: () async {
                await _signInWithGoogle();            
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                textStyle: const TextStyle(fontSize: 18), // Larger text size
                padding: const EdgeInsets.all(15), // Increased padding for larger touch area
              ), // Google's blue color in RGB
              icon: const Icon(FontAwesomeIcons.google, color: Colors.white),
              label: const Text('Sign in with Google',
                  style: TextStyle(color: Colors.white)),
            ),
            _verticalSpace(), //vertical space between button >on web
            ElevatedButton.icon(
              // Apple signin button
              onPressed: () async {
                await _signInWithApple(); // Call your Apple sign-in method
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Black background for contrast
                textStyle: const TextStyle(fontSize: 18), // Larger text size
                padding: const EdgeInsets.all(15), // Increased padding for larger touch area
              ),
              icon: const Icon(Icons.apple, color: Colors.white), // Apple icon in white
              label: const Text('Sign in with Apple',
                  style: TextStyle(color: Colors.white)),
            ),
            _verticalSpace(), //vertical space between button >on web
            _buildSignInButton(
              onPressed: SystemNavigator.pop,//passing pop as a value to onPressed
              iconData: Icons.exit_to_app,
              label: 'Exit stay logged in',
              backgroundColor: Colors.pinkAccent,
            ),
            _verticalSpace(), //vertical space between button >on web
            _buildSignInButton(//not working
              onPressed: () async {
                firebaseService.signOut();
                SystemNavigator.pop();//must call .pop() as a function here
              },
              iconData: Icons.exit_to_app,
              label: 'Exit & Logout',
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
