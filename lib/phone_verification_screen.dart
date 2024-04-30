import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'app_shell.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String verificationId;
  final FirebaseService firebaseService;

  const VerificationCodeScreen({
    super.key,
    required this.verificationId,
    required this.firebaseService,
  });

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _verificationCodeController = TextEditingController();

  Future<void> signInWithVerificationCode() async {
    final String verificationCode = _verificationCodeController.text;

    if (verificationCode.isNotEmpty) {
      final FirebaseAuth auth = FirebaseAuth.instance;

      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: verificationCode,
      );

      try {
        final UserCredential authResult =
            await auth.signInWithCredential(credential);
        final User? user = authResult.user;
        if (user != null) {
          // User successfully signed in
          print(
              '> > > phone_v_s.dart signInWithVerificationCode()> User signed in: ${user.uid}');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AppShell(),
            ),
          );
        } else {
          // Failed to sign in
          print(
              '> > > phone_v_s.dart signInWithVerificationCode()> Failed to sign in');
        }
      } catch (e) {
        // Handle sign-in error
        print(
            '> > > phone_v_s.dart signInWithVerificationCode()> Sign-in error: $e');
      }
    }
  }

  @override
  void dispose() {
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _verificationCodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: signInWithVerificationCode,
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneVerificationScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  const PhoneVerificationScreen({super.key, required this.firebaseService});

  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _phoneNumberController = TextEditingController();

  Future<void> verifyPhoneNumber() async {
    final String phoneNumber = _phoneNumberController.text;

    if (phoneNumber.isNotEmpty) {
      final FirebaseAuth auth = FirebaseAuth.instance;

      verificationCompleted(PhoneAuthCredential credential) async {
        // Handle verification completed
        await auth.signInWithCredential(credential);
        print(
            '> > > phone_v_s.dart _PhoneVerificationScreenState> Phone verification completed');
      }

      verificationFailed(FirebaseAuthException e) {
        // Handle verification failed
        print(
            '> > > phone_v_s.dart _PhoneVerificationScreenState> Phone verification failed: ${e.code}');
      }

      codeSent(String verificationId, int? resendToken) {
        // Navigate to verification screen and pass verificationId
        // to allow user to enter the verification code
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationCodeScreen(
              verificationId: verificationId,
              firebaseService: widget.firebaseService,
            ),
          ),
        );

        print(
            '> > > phone_v_s.dart _PhoneVerificationScreenState>Verification code sent: $verificationId');
      }

      codeAutoRetrievalTimeout(String verificationId) {
        print(
            '> > > phone_v_s.dart _PhoneVerificationScreenState>Auto retrieval timeout: $verificationId');
      }

      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    }
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: verifyPhoneNumber,
              child: const Text('Verify Phone Number'),
            ),
          ],
        ),
      ),
    );
  }
}
