// import 'package:cloud_functions/cloud_functions.dart';

// class StripeService {
//   FirebaseFunctions functions = FirebaseFunctions.instance;

//   Future<String?> createCheckoutSession() async {
//     try {
//       final HttpsCallable callable = functions.httpsCallable('createStripeCheckoutSession');
//       final response = await callable();
//       return response.data['sessionId'];
//     } catch (e) {
//       print('Error creating session: $e');
//       return null;
//     }
//   }

//   Future<String> createRefund() async {
//     try {
//       final HttpsCallable callable = functions.httpsCallable('createRefund');
//       final response = await callable();
//       return response.data['message'];
//     } catch (e) {
//       print('Error processing refund: $e');
//       return 'Failed to process refund';
//     }
//   }
// }


import 'package:cloud_functions/cloud_functions.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  FirebaseFunctions functions = FirebaseFunctions.instance;

  Future<String?> createCheckoutSession() async {
    try {
      final HttpsCallable callable = functions.httpsCallable('createStripeCheckoutSession');
      final response = await callable();
      return response.data['sessionId'];
    } catch (e) {
      print('Error creating session: $e');
      return null;
    }
  }

  Future<String> createRefund() async {
    try {
      final HttpsCallable callable = functions.httpsCallable('createRefund');
      final response = await callable();
      return response.data['message'];
    } catch (e) {
      print('Error processing refund: $e');
      return 'Failed to process refund';
    }
  }

  Future<void> createPaymentIntent(double amount) async {
    try {
      final HttpsCallable callable = functions.httpsCallable('createPaymentIntent');
      final response = await callable(<String, dynamic>{
        'amount': amount // Amount should be passed in the smallest currency unit (e.g., cents)
      });
      final String clientSecret = response.data['clientSecret'];

      // Confirm payment with the client secret obtained from your function
      await confirmPayment(clientSecret);
    } catch (e) {
      print('Error creating payment intent: $e');
      throw Exception('Failed to create payment intent');
    }
  }
// Usage in the Flutter App
// In your Flutter app, you would call createPaymentIntent when you want to initiate a payment. This could be triggered by a user action, such as pressing a "Pay Now" button. Here's an example of how you might use this method in a button's onPressed:
// ElevatedButton(
//   onPressed: () async {
//     try {
//       await stripeService.createPaymentIntent(2000); // Pass the amount in cents
//       // Show success message or navigate
//     } catch (error) {
//       // Handle or display error message
//     }
//   },
//   child: Text('Pay $20'),
// )

  Future<void> confirmPayment(String paymentIntentClientSecret) async {
    try {
    } catch (e) {
    }
  }
// Temporarily disabled due to ongoing issues *3 versions tried
// issue is  https://github.com/flutter-stripe/flutter_stripe/issues/1637
// Future<void> confirmPayment(String paymentIntentClientSecret) async {
//   try {
//     final PaymentIntentResult paymentResult = await Stripe.instance.confirmPayment(
//       paymentIntentClientSecret,
//       PaymentMethodParams.card(),
//     );
//     if (paymentResult.status == PaymentIntentsStatus.Succeeded) {
//       print('Payment completed successfully');
//     } else {
//       print('Payment failed: ${paymentResult.status}');
//     }
//   } catch (e) {
//     print('Error confirming payment: $e');
//     throw Exception('Payment confirmation failed');
//   }
// }

  // Future<void> confirmPayment(String paymentIntentClientSecret) async {
  //   try {
  //     // Confirm payment with the client secret obtained from your backend
  //     final PaymentIntentResult paymentResult = await Stripe.instance.confirmPayment(
  //       paymentIntentClientSecret,
  //       PaymentMethodParams.card(
  //         paymentMethodData: PaymentMethodDataCard(
  //           // You can specify additional card parameters here if needed
  //         ),
  //       ),
  //     );

  //     // Handle the payment intent result
  //     if (paymentResult.status == PaymentIntentsStatus.Succeeded) {
  //       print('Payment completed successfully');
  //     } else {
  //       print('Payment failed: ${paymentResult.status}');
  //     }
  //   } catch (e) {
  //     print('Error confirming payment: $e');
  //     throw Exception('Payment confirmation failed');
  //   }
  // }

  // Future<void> confirmPayment(String clientSecret) async {
  //   try {
  //     final paymentIntentResult = await Stripe.instance.confirmPayment(
  //       clientSecret,
  //       PaymentMethodParams.card(
  //         paymentMethodData: PaymentMethodData(
  //           type: 'Card', // Define the type as Card
  //         ),
  //       ),
  //     );
  //     // Handle the payment intent result
  //     // e.g., check if the payment is successful
  //     if (paymentIntentResult.status == PaymentIntentsStatus.Succeeded) {
  //       print('Payment completed successfully');
  //     } else {
  //       print('Payment failed: ${paymentIntentResult.status}');
  //     }
  //   } catch (e) {
  //     print('Error confirming payment: $e');
  //     throw Exception('Payment confirmation failed');
  //   }
  // }


}
