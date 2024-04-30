//module membership_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:cloud_functions/cloud_functions.dart';// for payments
import 'stripe_service.dart';
import 'firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';// for User
import 'paypal_webview.dart'; // Ensure you have this import

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  _MembershipPageState createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    MembershipRegistrationPage(),
    MembershipPaymentPage(),
    PayPalPaymentPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Register',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'PayPal',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class PayPalPaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PayPal Payment'),
      ),
      body: WebViewApp(), //PayPalWebView(), // Using the previously created WebView
    );
  }
}

class MembershipRegistrationPage extends StatefulWidget {
  @override
  _MembershipRegistrationPageState createState() => _MembershipRegistrationPageState();
}

class _MembershipRegistrationPageState extends State<MembershipRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';

  // void _register() {
  //   if (_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save();
  //     // Here, add logic to save data to Firestore
  //   }
  // }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      User? user = Provider.of<User?>(context, listen: false);
      var firebaseService = Provider.of<FirebaseService>(context, listen: false);
      if (user != null) {
        bool success = await firebaseService.saveMemberData(_name, _email, user.uid);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration successful!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register. Please try again.')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
            onSaved: (value) => _name = value!,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
            onSaved: (value) => _email = value!,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter an email address';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: _register,
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}

class MembershipPaymentPage extends StatefulWidget {
  @override
  _MembershipPaymentPageState createState() => _MembershipPaymentPageState();
}

class _MembershipPaymentPageState extends State<MembershipPaymentPage> {
  @override
  Widget build(BuildContext context) {
    // Access StripeService from the provider or create a new instance
    final stripeService = Provider.of<StripeService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: Center(
        child: Text("We are currently working on improving the payment process. Stripe payments will be available soon. Thank you for your patience."),
      ),
      // body: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     ElevatedButton(
      //       onPressed: () => _processPayment(stripeService),
      //       child: Text('Pay Membership Fee'),
      //     ),
      //     SizedBox(height: 20),
      //     ElevatedButton(
      //       onPressed: () => _processRefund(stripeService),
      //       child: Text('Refund Last Payment'),
      //     ),
      //   ],
      // ),
    );
  }

  void _processPayment(StripeService stripeService) async {
    try {
      await stripeService.createPaymentIntent(2000); // Assuming $20.00 payment
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful!'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing payment: $e'))
      );
    }
  }

  void _processRefund(StripeService stripeService) async {
    try {
      String refundStatus = await stripeService.createRefund();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(refundStatus))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing refund: $e'))
      );
    }
  }
}

