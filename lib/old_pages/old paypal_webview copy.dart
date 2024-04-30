// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'dart:convert'; // For Encoding

// class PayPalWebView extends StatelessWidget {
//   final String htmlContent = '''
// <!DOCTYPE html>
// <html>
// <head>
// <title>PayPal Button</title>
// </head>
// <body>
//   <!-- PayPal button code -->
//   <div id="paypal-button-container"></div>
//   <script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&currency=USD"></script>
//   <script>
//     paypal.Buttons({
//       createOrder: function(data, actions) {
//         return actions.order.create({
//           purchase_units: [{
//             amount: {
//               value: '10.00' // Can be dynamically set
//             }
//           }]
//         });
//       },
//       onApprove: function(data, actions) {
//         return actions.order.capture().then(function(details) {
//           alert('Transaction completed by ' + details.payer.name.given_name);
//           // Optionally, you can send transaction details to your server
//         });
//       }
//     }).render('#paypal-button-container');
//   </script>
// </body>
// </html>
// ''';

//   @override
//   Widget build(BuildContext context) {
//     return WebView(
//       initialUrl: Uri.dataFromString(htmlContent, mimeType: 'text/html', encoding: utf8).toString(),
//       javascriptMode: JavascriptMode.unrestricted,
//     );
//   }
// }
