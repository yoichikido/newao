// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// // import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// // import 'package:firebase_storage/firebase_storage.dart';
// import 'firebase_service.dart';
// import 'login_page.dart';
// import 'package:intl/intl.dart'; //just for date now
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert' as convert;
// import 'package:http/http.dart' as http;
// import 'dart:async';
// import 'firebase_options.dart'; //<<<< might need this
// // Feature flags
// const bool goDirectlyToHomePage = false; //swich to test
// //true to use MyStreamBuilderApp() to listen to firebase auth state changes
// // to increment user device count
// const bool useStreamBuilder = true;
// //extensions
// extension StringInsertionExtension on String {
//   String insert(int index, String other) {
//     return substring(0, index) + other + substring(index, length);
//   }
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized(); //prepares flutter to run
//   if (kIsWeb) {
//     //if is running in web browser //web version needs these options
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: "AIzaSyDHhaEiAz9IZek-UB_TtYQvlrk8e2uwsG4",
//         authDomain: "nov-end-copy.firebaseapp.com",
//         projectId: "nov-end-copy",
//         storageBucket: "nov-end-copy.appspot.com",
//         messagingSenderId: "765973138593",
//         appId: "1:765973138593:web:9b433de30199637cc534e0"
//       ),
//     );
//   } else {
//     // await Firebase.initializeApp(); //app version does not work with web options
//     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
//   }
//   final firebaseService = FirebaseService(
//     auth: FirebaseAuth.instance,
//     firestore: FirebaseFirestore.instance,
//     storage: FirebaseStorage.instance,
//   );
//   // FirebaseAnalytics analytics = FirebaseAnalytics();
//   FirebaseAnalytics analytics = FirebaseAnalytics.instance;

//   print(">>>___in main() Direct to homepage is $goDirectlyToHomePage");
//   if (!goDirectlyToHomePage) {
//     runApp(useStreamBuilder
//         ? MyStreamBuilderApp(firebaseService: firebaseService)
//         : MyApp(firebaseService: firebaseService));
//   } else {
//     runApp(MyAppShortcut(firebaseService: firebaseService)); //not working
//   }
// }

// class MyAppShortcut extends StatelessWidget {
//   final FirebaseService firebaseService;
//   const MyAppShortcut({super.key, required this.firebaseService});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Simple Text Editor',
//       theme: ThemeData(
//         primarySwatch: Colors.red,
//       ),
//       home: MyHomePage(
//         // title: 'NADSIMPLE TEXT EDITOR',
//         // moreThanOneDeviceConnected: false,
//         firebaseService: firebaseService,
//         uid: '', // add appropriate UID value
//       ),
//     );
//   }
// }

// class MyStreamBuilderApp extends StatelessWidget {
//   final FirebaseService firebaseService;
//   final String? uid, lastText;

//   const MyStreamBuilderApp({
//     super.key, // Add Key? key parameter here
//     required this.firebaseService,
//     this.uid,
//     String? initialLastText,
//   })  : lastText = initialLastText ?? ''; // Call the superclass constructor with the provided key

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Simple Text Editor',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: StreamBuilder<User?>(
//         stream: firebaseService.authStateChanges(),
//         builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
//           if (snapshot.connectionState == ConnectionState.active) {
//             if (snapshot.data != null) {
//               return MyHomePage(
//                 firebaseService: firebaseService,
//                 uid: snapshot.data!.uid,
//                 // moreThanOneDeviceConnected: moreThanOneDeviceConnected,
//               );
//             } else {
//               // User is not logged in
//               return LoginPage(firebaseService: firebaseService, uid: '');
//             }
//           } else {
//             // Auth state is still loading
//             return const CircularProgressIndicator();
//           }
//         },
//       ),
//     );
//   }
// }


// class MyApp extends StatelessWidget {
//   final FirebaseService firebaseService;
//   final String? uid, lastText;
//   const MyApp({
//     super.key,
//     required this.firebaseService,
//     this.uid,
//     String? initialLastText, //using different name for parameter
//   }) : lastText = initialLastText ?? ''; //default value of empty string
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Simple Text Editor', //title here seems to be required
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//       ),
//       home: FutureBuilder(
//         future: _loadInitialScreen(context),
//         builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             if (snapshot.data != null) {
//               return MyHomePage(
//                 // title: 'NTE', //NADSIMPLE TEXT EDITOR
//                 // moreThanOneDeviceConnected: false,
//                 firebaseService: firebaseService,
//                 uid: snapshot.data!.uid,
//               );
//             } else {
//               return LoginPage(firebaseService: firebaseService, uid: '');
//             }
//           } else {
//             return const CircularProgressIndicator(); // Show a loading indicator while waiting
//           }
//         },
//       ),
//     );
//   }

//   Future<User?> _loadInitialScreen(BuildContext context) async {
//     print(
//         ">>+++++ In _loadInitialScreen, going to use signInWithLastUsedMethod instead of getLastUsedAuthMethod");
//     String? lastUsedAuthMethod = await firebaseService.getLastUsedAuthMethod();
//     print("lastUsedAuthMethod $lastUsedAuthMethod");
//     //User? user = await
//     print("Last auth method: ");
//     print(lastUsedAuthMethod);
//     if (lastUsedAuthMethod != null) {
//       User? user = await firebaseService.signInWithLastUsedMethod();
//       firebaseService.incrementUserDeviceCount(user!.uid); // increment error
//       return user;
//     }
//     return null;
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage(
//       {super.key,
//       // required this.title,
//       // required this.moreThanOneDeviceConnected, // Include it in the constructor
//       required this.firebaseService,
//       required this.uid,
//       this.lastText});

//   // final String title;
//   final FirebaseService firebaseService;
//   final String uid;
//   final String? lastText;
//   // final bool moreThanOneDeviceConnected; // Add the parameter here
//   @override
//   _MyHomePageState createState() => _MyHomePageState(uid: uid);
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final TextEditingController _textController = TextEditingController();
//   final FocusNode _textFieldFocusNode = FocusNode();
//   User? _user; // The user object from Firebase Authentication
//   final TextEditingController _searchController =
//       TextEditingController(); //>to>move>to>SearchReplaceFields
//   final TextEditingController _replaceController =
//       TextEditingController(); //>to>move>to>SearchReplaceFields
//   // bool moreThanOneDeviceConnected = false;
//   String _uid; //do not set to final as it is modified
//   String _previousReplaceText =
//       ''; //  to store the previous replace text to allow reset of replace count
//   bool _showSearchReplaceFields = false;
//   bool _showSettingsFields = false;
//   double textFieldHeightAdjustment = 0.0;
//   //for search----------------*moved to class SearchReplaceFields
//   List<String> _searchHistory = [];
//   int _foundItemCount = 0;
//   int _replacedItemCount = 0;
//   List<int> _foundIndices = [];
//   int currentIndex = 0;
//   // For saving regularly
//   Timer? _firebaseSaveTimer; // Timer for saving to Firebase periodically
//   bool _hasTextChanges =
//       false; // Track if text has changed since last Firebase save

//   // List<String> get foundSubstrings {
//   //   // Return the list of found substrings
//   //   return _foundSubstrings;
//   // }

//   _MyHomePageState({required String uid})
//       : _uid = uid; // Initialize _uid in the constructor
//   @override
//   void initState() {
//     super.initState();
//     _loadSearchHistory(); //moved to searchreplacefields class
//     _loadText();
//     // Start a timer that triggers the save to Firebase every five
//     void startFirebaseSaveTimer() {
//       _firebaseSaveTimer?.cancel(); // Cancel the previous timer if it exists
//       // Start a new periodic timer
//       _firebaseSaveTimer = Timer.periodic(const Duration(minutes: 5), (_) {
//         if (_hasTextChanges) {
//           widget.firebaseService.saveTextToFirestore(_textController.text,
//               _uid); // Save text to Firebase (or Firestore, as needed)
//           _hasTextChanges = false;
//         }
//       });
//     }

//     // _firebaseSaveTimer = Timer.periodic(Duration(minutes: 5), (_) {
//     //   if (_hasTextChanges) {
//     //     _saveTextToFirebase();//firebase or firestore--need to check
//     //     _hasTextChanges = false;
//     //   }
//     // }
//     // initially added listener to set to 0 but this happened when text is selected and not changed so commenting out
//     // add listener to replace controller to reset replace count when replace text updated
//     // _replaceController.addListener(() {
//     //   setState(() {
//     //     _replacedItemCount = 0; // Reset the count of replacements to zero.
//     //   });
//     // });
//     _searchController
//         .addListener(_onSearchTextChanged); // to allow seach as you type
//     if (widget.lastText != null) {
//       _textController.text = widget.lastText!;
//     }
//     widget.firebaseService.getCurrentUser().then((User? user) {
//       if (user != null) {
//         setState(() {
//           _uid = user.uid;
//         });
//         _getLastSavedText();
//       }
//     });
//   }

//   @override //called when the app gets closed or switched out
//   void dispose() {
//     // _scrollController
//     // .dispose(); // ###test--issue not here### Dispose the scroll controller
//     // Save the text locally on the phone using SharedPreferences
//     String textToSave = _textController.text;
//     _firebaseSaveTimer
//         ?.cancel(); // Cancel the timer when the widget is disposed
//     // saveTextLocally(textToSave);
//     // Save the text to Firebase Firestore
//     widget.firebaseService.saveTextToFirestore(_textController.text, _uid);
//     super.dispose();
//   }

//   //____________SEARCH REPLACE FUNCTIONS THAT WERE ONCE IN A CLASS OF THEIR OWN_______________
//   void goToNextInstance() {
//     // if (_foundItemCount == 0) {
//     //   _performSearch();
//     // }
//     print('>>>___ currentIndex $currentIndex');
//     if (_foundIndices.isNotEmpty) {
//       currentIndex = (currentIndex + 1) % _foundIndices.length;
//       //modulo operator % used to reset currentIndex to 0 when it reaches _foundIndices.length
//       int position = _foundIndices[currentIndex];
//       // Remove focus from the TextField. Neccessary to get focus the second time
//       _textFieldFocusNode.unfocus();
//       Future.delayed(const Duration(milliseconds: 30), () {
//         //delays allows unfocus to take effect so the enxt work can be focused correctly, if does not work, chang to 50 to 100ms
//         _textFieldFocusNode.requestFocus();
//       });
//       // _textFieldFocusNode.requestFocus(); //<- this onl work first time>
//       _textController.selection = TextSelection(
//         baseOffset: position,
//         extentOffset: position + _searchController.text.length,
//       );
//     }
//   }

//   void goToPreviousInstance() {
//     if (_foundIndices.isNotEmpty) {
//       currentIndex =
//           (currentIndex - 1 + _foundIndices.length) % _foundIndices.length;
//       int position = _foundIndices[currentIndex];
//       _textFieldFocusNode.unfocus();
//       Future.delayed(const Duration(milliseconds: 30), () {
//         _textFieldFocusNode.requestFocus();
//       });

//       _textController.selection = TextSelection(
//         baseOffset: position,
//         extentOffset: position + _searchController.text.length,
//       );
//     }
//   }

//   void _performSearch() {
//     String searchTerm = _searchController.text;
//     String text = _textController.text;
//     List<int> foundIndices = [];
//     int index = 0;
//     if (searchTerm.isNotEmpty) {
//       //to avoid infinite search loop
//       while (index != -1) {
//         index = text.indexOf(
//             searchTerm, index); // .indexOf returns -1 if nothing found
//         if (index != -1) {
//           foundIndices.add(index); //adds location of the current search term
//           index += searchTerm.length; //start search again after the search term
//         }
//       }
//     }
//     // Update the found item count and the text controller's selection
//     //###test--issue not here###
//     setState(() {
//       _foundItemCount = foundIndices.length;
//     });

//     _foundIndices =
//         foundIndices; // Store the found indices and substrings in the state variables

//     _addToSearchHistory(searchTerm); // Add the search term to the history
//   }

//   void _performReplace() {
//     String searchTerm = _searchController.text;
//     String replaceTerm = _replaceController.text;
//     String text = _textController.text;
//     // Perform the replace operation
//     TextSelection selection = _textController.selection;
//     int startIndex = selection.start;
//     int endIndex = selection.end;
//     String selectedText = text.substring(startIndex, endIndex);
//     String newText = text.replaceRange(startIndex, endIndex, replaceTerm);
//     // Update the text controller with the replaced text
//     _textController.text = newText;
//     // Update the replaced item count

//     // Update the found indices and substrings if necessary
//     if (_foundIndices.isNotEmpty) {
//       // setState(() {
//       //   _replacedItemCount++;
//       // });
//       for (int i = 0; i < _foundIndices.length; i++) {
//         int index = _foundIndices[i];
//         if (index >= endIndex) {
//           _foundIndices[i] += replaceTerm.length - selectedText.length;
//         }
//       }
//       // for (int i = 0; i < foundSubstrings.length; i++) {
//       //   String substring = foundSubstrings[i];
//       //   if (i < foundSubstrings.length - 1 &&
//       //       substring.contains(selectedText)) {
//       //     foundSubstrings[i] =
//       //         substring.replaceFirst(selectedText, replaceTerm);
//       //   }
//       // }
//     }
//     goToNextInstance();
//     // Add the search term to the history
//     _addToSearchHistory(searchTerm);
//     // Update the search and replace count if the replace text has changed
//     if (_previousReplaceText != replaceTerm) {
//       setState(() {
//         _replacedItemCount =
//             1; // Reset the replace count to 1 for the new replace term.
//       });
//     } else {
//       setState(() {
//         _replacedItemCount++; // Increment the replace count for the same replace term.
//       });
//     }
//     // Store the current replace term as the previous replace text for the next comparison
//     _previousReplaceText = replaceTerm;
//     // Perform the search to find the updated occurrences of the search term with the new replace term
//     _performSearch();
//   }

//   void _performReplaceAll() {
//     if (_textController.text.isNotEmpty) {
//       // Save a backup
//       String searchTerm = _searchController.text;
//       String replaceTerm = _replaceController.text;
//       String text = _textController.text;
//       print(">>before replace all>>save to cloud clicked");
//       widget.firebaseService.saveTextToFirestore(_textController.text, _uid);

//       // Perform the replace operation
//       String newText = text.replaceAll(searchTerm, replaceTerm);

//       // Update the text controller with the replaced text
//       _textController.text = newText;

//       // Calculate the number of replacements and add to _replacedItemCount
//       int numReplacements = (text.length - newText.length) ~/ searchTerm.length;
//       setState(() {
//         _replacedItemCount += numReplacements;
//       });
//       // Perform the search to find the updated occurrences of the search term with the new replace term
//       _performSearch();
//       // Add the search term to the history
//       _addToSearchHistory(searchTerm);
//     }
//   }

//   void _onSearchTextChanged() {
//     // Perform the search whenever the text changes
//     _performSearch();
//   }

//   void _loadSearchHistory() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _searchHistory = prefs.getStringList('searchHistory') ?? [];
//     });
//   }

//   void _saveSearchHistory() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setStringList('searchHistory', _searchHistory);
//   }

//   void _addToSearchHistory(String searchTerm) {
//     if (!_searchHistory.contains(searchTerm)) {
//       setState(() {
//         _searchHistory.add(searchTerm);
//       });
//       _saveSearchHistory();
//     }
//   }

//   void _clearSearchHistory() {
//     setState(() {
//       _searchHistory.clear();
//     });
//     _saveSearchHistory();
//   }

//   //____________TO HERE SEARCH REPLACE FUNCTIONS THAT WERE ONCE IN A CLASS OF THEIR OWN_______________
//   //~~~~~~~~~~~~~~~~~~~Text loading, saving functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//   void _loadText() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? savedText = prefs.getString('savedText');
//     setState(() {
//       _textController.text = savedText ?? "";// Assign an empty string if savedText is null
//     });
//     }

// // Function to save text locally on the phone using SharedPreferences
//   void saveTextLocally(String text) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString('localTextSaveOnAbruptExit', text);
//   }

//   void _saveTextLocally() async {
//     String text = _textController.text;
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString('savedText', text);
//     print('>>>__ saved ${text.substring(0, 30)}');
//   }

//   void _handleTextChanges(String newText) {
//     //to save text regularly
//     setState(() {
//       _hasTextChanges = true; // Set the flag to true when text changes
//     });
//     _saveTextLocally(); // Save to SharedPreferences immediately on text change
//   }

//   Future<void> _getUser() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     setState(() {
//       _user = user;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     double textFieldHeight = MediaQuery.of(context).size.height -
//         (kIsWeb ? 80.0 : 360.0); //adjust to height of keyboard when it pops up
//     if (_showSearchReplaceFields) {
//       textFieldHeight -= 60.0; //adjust to height of find replace fields
//     }
//     if (_showSettingsFields) {
//       textFieldHeight -= 50.0; //adjust to height of setting fields
//     }
//     return Scaffold(
//       resizeToAvoidBottomInset:
//           false, //set to false to reset when keyboard pops up
//       appBar: AppBar(
//         //____________ AppBar + --------------------
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         // title: Text(widget.title),//to make room for more buttons
//         actions: <Widget>[
//           //find icon with subscript as # found
//           Stack(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.search),
//                 onPressed: () {
//                   setState(() {
//                     // _searchController.text = '';
//                     // _replaceController.text = '';
//                     _showSearchReplaceFields
//                         ? _showSearchReplaceFields = false
//                         : _showSearchReplaceFields = true;
//                     // _addToSearchHistory(_searchController.text);
//                   });
//                 },
//               ),
//             ],
//           ),
//           //settings
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               print('settings icon in appbar pressed');
//               setState(() {
//                 _showSettingsFields
//                     ? _showSettingsFields = false
//                     : _showSettingsFields = true;
//               });
//             },
//           ),
//           //Icons.timer
//           IconButton(
//             icon: const Icon(Icons.timer),
//             onPressed: () {
//               print(">>appbar>>timestamp clicked");
//               _setTimestampToClipboard(context);
//               _pasteFromClipboard(); // at cursor or end if cursor not in field
//             },
//           ),
//           //_copyToClipboard
//           IconButton(
//             icon: const Icon(Icons.content_copy),
//             onPressed: () {
//               print(">>appbar>>copy clicked");
//               _copyToClipboard();
//             },
//           ),
//           Stack(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.paste),
//                 onPressed: () {
//                   print(">>appbar>>paste clicked");
//                   _pasteFromClipboard();
//                 },
//               ),
//             ],
//           ), //cloud_upload_sharp
//           //todo>> make stack show deviceCount number of add file saving saving change functionality
//           IconButton(
//             onPressed: () {
//               print(">>appbar>>save to cloud clicked");
//               String? textContent = _textController.text;
//               if (_textController.text.isNotEmpty) {
//                 widget.firebaseService
//                     .saveTextToFirestore(_textController.text, _uid);
//               }
//             },
//             icon: const ColorFiltered(
//               colorFilter:
//                   ColorFilter.mode(Colors.transparent, BlendMode.srcATop),
//               // colorFilter: moreThanOneDeviceConnected
//               //     ? ColorFilter.mode(Colors.deepOrangeAccent, BlendMode.srcATop)
//               // : ColorFilter.mode(Colors.transparent, BlendMode.srcATop),
//               child: Icon(Icons.cloud_upload_sharp),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.exit_to_app),
//             onPressed: () {
//               print("exit clicked");
//               String? textContent = _textController.text;
//               if (_textController.text.isNotEmpty) {
//                 widget.firebaseService
//                     .saveTextToFirestore(_textController.text, _uid);
//                 widget.firebaseService.decrementUserDeviceCount(_uid);
//                 //_textController.clear();
//               }
//               print(
//                   '>>>___ Saved auth method: ${widget.firebaseService.getLastUsedAuthMethod()}');
//               SystemNavigator.pop(); //Exit app
//             },
//           ),
//           if (_user != null) //user icon
//             CircleAvatar(
//               backgroundImage: NetworkImage(_user!.photoURL ?? ''),
//             ),
//         ],
//       ),
//       //================ End of AppBar/Start Drawer =====================
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             const DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//               child: Text('Menu'),
//             ),
//             ListTile(
//               title: const Text('Change user screen'),
//               onTap: () async {
//                 // Update the state of the app
//                 String? textContent = _textController.text;
//                 // Save to Firestore
//                 print('Saving text: $textContent');
//                 print('User ID>>>>>>>: $_uid');
//                 if (_textController.text.isNotEmpty) {
//                   widget.firebaseService
//                       .saveTextToFirestore(_textController.text, _uid);
//                   _textController.clear();
//                 }
//                 // await widget.firebaseService.decrementUserDeviceCount(_uid);
//                 await widget.firebaseService.signOut();
//                 await widget.firebaseService
//                     .removeLastUsedAuthMethod(); //locally
                
//                 Navigator.pop(context);

//                 // Assuming you have access to firebaseService through a widget property
                
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => LoginPage(
//                       firebaseService: widget.firebaseService,
//                       uid:
//                           '', // Pass an empty string or a default value if you don't have a uid when logged out
//                     ),
//                   ),
//                 );
//                 // Then close the drawer--cannot have 2 Navigators
                
//               },
//             ),
//             ListTile(
//               title: const Text('Save'),
//               onTap: () async {
//                 // Update the state of the app
//                 String? textContent = _textController.text;
//                 print('Saving text: $textContent');
//                 print('User  >>>>>: $_uid');
//                 if (_textController.text.isNotEmpty) {
//                   bool success = await widget.firebaseService
//                       .saveTextToFirestore(_textController.text, _uid);
//                   if (!success) {
//                     _showErrorSnackbar(
//                         context, 'Error saving text to Firestore');
//                   } else {
//                     //_textController.clear();
//                   }
//                 } else {
//                   print('>>>> Text is empty or UID is null, <<<< not saving.');
//                 }
//                 // Then close the drawer
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('Save & exit'),
//               onTap: () {
//                 // Update the state of the app
//                 String? textContent = _textController.text;
//                 if (_textController.text.isNotEmpty) {
//                   widget.firebaseService
//                       .saveTextToFirestore(_textController.text, _uid);
//                   _textController.clear();
//                 }
//                 print(
//                     'Saved auth method: ${widget.firebaseService.getLastUsedAuthMethod()}');
//                 // widget.firebaseService.decrementUserDeviceCount(_uid);
//                 SystemNavigator.pop(); //Exit app
//               },
//             ),
//             // ListTile(
//             //   title: const Text('Print saved text'),
//             //   onTap: () {
//             //     _fetchAndPrintTexts();
//             //     Navigator.pop(context);
//             //   },
//             // ),
//             ListTile(
//               title: const Text('Append user info'),
//               onTap: () async {
//                 User? user = await widget.firebaseService.getCurrentUser();
//                 _addUserInfoToText(context, user);
//                 //              _showUserInfoDialog(context, user);
//                 Navigator.pop(context);
//               },
//             ),
//             // ListTile(
//             //   title: const Text('login method'),
//             //   onTap: () async {
//             //     print(
//             //         '--->>> Saved auth method is: ${widget.firebaseService.getLastUsedAuthMethod()}');
//             //     Navigator.pop(context);
//             //   },
//             // ),
//             ListTile(
//               title: const Text('Save logout & exit'),
//               onTap: () async {
//                 String? textContent = _textController.text;
//                 if (_textController.text.isNotEmpty) {
//                   widget.firebaseService
//                       .saveTextToFirestore(_textController.text, _uid);
//                   _textController.clear();
//                 }
//                 // await widget.firebaseService.decrementUserDeviceCount(_uid);
//                 await widget.firebaseService.signOut();
//                 await widget.firebaseService
//                     .removeLastUsedAuthMethod(); //remove locally
//                 SystemNavigator.pop(); //Exit app
//               },
//             ),
//             ListTile(
//               title: const Text('Exit without loggout or save'),
//               onTap: () async {
//                 // await widget.firebaseService.decrementUserDeviceCount(_uid);
//                 String? textContent = _textController.text;
//                 SystemNavigator.pop(); //Exit app
//               },
//             ),
//             // ListTile(
//             //   title: const Text('print latest tweet'),
//             //   onTap: () async {
//             //     String? latestTweet = await getLatestTweet();
//             //     print(latestTweet);
//             //     Navigator.pop(context); //Exit app
//             //   },
//             // ),
//           ],
//         ),
//       ),
//       //================ End of drawer/ Start BODY =====================
//       //________________________________________________________________
//       body: Column(
//         children: [
//           //============== show Settings Row from AppBar
//           //TODO add adjustment to text-saving timeing
//           Visibility(
//             visible: _showSettingsFields,
//             child: Row(
//               children: [
//                 const SizedBox(width: 8.0),
//                 GestureDetector(
//                   onLongPress: () {
//                     setState(() {
//                       textFieldHeightAdjustment -= 20.0;
//                     }); // Handle long press
//                   },
//                   child: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           //trigger widget tree rebuild
//                           textFieldHeightAdjustment -= 1.0;
//                         });
//                         print(
//                             'decrease A- pressed text field now $textFieldHeight');
//                       },
//                       icon: const Icon(Icons.remove)),
//                 ),
//                 const SizedBox(width: 8.0),
//                 GestureDetector(
//                   onLongPress: () {
//                     setState(() {
//                       textFieldHeightAdjustment += 20.0;
//                     }); // Handle long press
//                   },
//                   child: IconButton(
//                     icon: const Icon(Icons.add_circle_outline_outlined),
//                     onPressed: () {
//                       setState(() {
//                         textFieldHeightAdjustment += 1.0;
//                       }); // Handle regular press
//                     },
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () {
//                     setState(() {
//                       _showSettingsFields = false;
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//           //============== show Search and Replace Row from AppBar
//           Visibility(
//             visible: _showSearchReplaceFields,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: const InputDecoration(
//                       hintText: 'Search',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: goToNextInstance,
//                   icon: const Icon(Icons.arrow_downward_outlined),
//                 ),
//                 IconButton(
//                   onPressed: goToPreviousInstance,
//                   icon: const Icon(Icons.arrow_upward),
//                 ),
//                 // IconButton(
//                 //   onPressed: performReplace,
//                 //   icon: const Icon(Icons.find_replace_sharp),
//                 // ),
//                 Expanded(
//                   child: TextField(
//                     controller: _replaceController,
//                     decoration: const InputDecoration(
//                       hintText: 'Replace',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onLongPress: () {
//                     _performReplaceAll();
//                   },
//                   child: Stack(children: [
//                     IconButton(
//                       onPressed: _performReplace,
//                       icon: const Icon(Icons.find_replace_sharp),
//                     ),
//                     if (_foundItemCount > 0)
//                       Positioned(
//                         top: 6.0,
//                         right: 6.0,
//                         child: Container(
//                           padding: const EdgeInsets.all(2.0),
//                           decoration: const BoxDecoration(
//                             color: Colors.red,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Text(
//                             _foundItemCount.toString(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10.0,
//                             ),
//                           ),
//                         ),
//                       ),
//                     if (_replacedItemCount > 0)
//                       Positioned(
//                         bottom: 6.0,
//                         right: 6.0,
//                         child: Container(
//                           padding: const EdgeInsets.all(2.0),
//                           decoration: const BoxDecoration(
//                             color: Colors.green,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Text(
//                             _replacedItemCount.toString(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10.0,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ]),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(
//             height: textFieldHeight +
//                 textFieldHeightAdjustment, // Adjust text field height at top
//             child: SingleChildScrollView(
//               child: TextField(
//                 controller: _textController,
//                 onChanged: _handleTextChanges, // to save regularly
//                 focusNode: _textFieldFocusNode, //to select text
//                 maxLines: null,
//                 keyboardType: TextInputType.multiline,
//                 decoration: const InputDecoration(
//                   hintText: 'Enter your text here *this is a test version so much functionality might not be working correctly',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),
//           ),
//           Scrollbar(
//             thickness: 8.0,
//             child: ListView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               shrinkWrap: true,
//               children: const [
//                 // ... your additional scrollable content ...
//               ],
//             ),
//           ),
//           // ),
//           // ),
//         ],
//       ),
//     );
//   }

//   void _setTimestampToClipboard(BuildContext context) {
//     //context necessary to get local date from up the widget tree
//     DateTime now = DateTime.now();
//     String locale = Localizations.localeOf(context).toLanguageTag();
//     String formattedDate = DateFormat.yMd(locale)
//         .add_jms()
//         .format(now); //using devices local format
//     //    String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
//     Clipboard.setData(ClipboardData(text: formattedDate));
//   }

//   Future<void> _pasteFromClipboard() async {
//     final data = await Clipboard.getData(Clipboard.kTextPlain);
//     final String pastedText = data?.text ?? '';
//     final textSelection = _textController.selection;
//     final newText = _textController.text.replaceRange(
//       textSelection.start,
//       textSelection.end,
//       pastedText,
//     );
//     _textController.text = newText;
//     _textController.selection = TextSelection.collapsed(
//         offset: textSelection.start + pastedText.length);
//   }

//   Future<String?> getLatestTweet() async {
//     //code working, but getting 403 error back
//     final response = await http.get(
//       Uri.parse(
//           'https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=[Screen_Name]&count=1'),
//       headers: {
//         'Authorization': 'Bearer [bearer token from my twitter app dev page]',
//       },
//     );
//     if (response.statusCode == 200) {
//       List<dynamic> jsonResponse = convert.jsonDecode(response.body);
//       return jsonResponse[0]['text'];
//     } else {
//       print('twitter Request failed with status: ${response.statusCode}.');
//       return null;
//     }
//   }

//   void _copyToClipboard() {
//     final textSelection = _textController.selection;
//     String textToCopy;

//     // Check if there's a selection
//     if (textSelection.start != textSelection.end) {
//       // Copy the selected text
//       textToCopy = _textController.text
//           .substring(textSelection.start, textSelection.end);
//     } else {
//       // Copy all the text
//       textToCopy = _textController.text;
//     }

//     Clipboard.setData(ClipboardData(text: textToCopy));
//   }

//   void _fetchAndPrintTexts() async {
//     List<Map<String, dynamic>> texts =
//         await widget.firebaseService.getTextsFromFirestore(_uid);
//     print('Fetched texts:');
//     for (Map<String, dynamic> text in texts) {
//       print(text['content']);
//     }
//   }

//   void _getLastSavedText() async {
//     String? lastSavedText = await widget.firebaseService.getLastSavedText(_uid);
//     setState(() {
//       _textController.text = lastSavedText ?? ""; // Assign an empty string if lastSavedText is null

//     });
//     } // puts text from firebase to the text box

//   void _addUserInfoToText(BuildContext context, User? user) {
//     String providerInfo = '';
//     if (user?.providerData.isNotEmpty ?? false) {
//       // Access provider data here
//       final provider = user!.providerData[0];
//       providerInfo = 'Provider: ${provider.providerId}';
//     } else {
//       providerInfo = 'No provider data';
//     }
//     String userInfo = 'User information: \n'
//         'User ID: ${user?.uid ?? "N/A"}\n'
//         'Email: ${user?.email ?? "N/A"}\n'
//         'Display Name: ${user?.displayName ?? "N/A"}\n'
//         'Anonymous? ${user?.isAnonymous}\n'
//         'Email verified? ${user?.emailVerified}\n'
//         '$providerInfo\n';
//     _textController.text += userInfo;
//   }

//   void _showUserInfoDialog(BuildContext cuserInfoontext, User? user) {
//     String providerInfo = '';

//     if (user?.providerData.isNotEmpty ?? false) {
//       // Access provider data here
//       final provider = user!.providerData[0];
//       providerInfo = 'Provider: ${provider.providerId}';
//     } else {
//       providerInfo = 'No provider data';
//     }
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('User Information'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text('UID: ${user?.uid ?? "N/A"}'),
//                 Text('Display Name: ${user?.displayName ?? "N/A"}'),
//                 Text('Email: ${user?.email ?? "N/A"}'),
//                 Text(providerInfo),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Close'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showErrorSnackbar(BuildContext context, String message) {
//     final snackBar = SnackBar(
//       content: Text(message),
//       backgroundColor: Colors.blueGrey,
//     );
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
//   // Widget build
// } // Class _MyHomePageState

// class AuthLoader extends StatefulWidget {
//   final FirebaseService firebaseService;

//   const AuthLoader({super.key, required this.firebaseService});

//   @override
//   _AuthLoaderState createState() => _AuthLoaderState();
// }

// class _AuthLoaderState extends State<AuthLoader> {
//   @override
//   void initState() {
//     super.initState();
//     _loadAuthMethodAndSignIn(context);
//   }

//   Future<void> _loadAuthMethodAndSignIn(BuildContext context) async {
//     // ... The rest of your _loadAuthMethodAndSignIn function
//   }
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }