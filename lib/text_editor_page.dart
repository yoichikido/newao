import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; //just for date now
import 'app_state.dart'; // Adjust the import path based on your project structure
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // for Clipboard
import 'dart:async'; // for Timer
import 'firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';// for User

class TextEditorPage extends StatefulWidget {
  // final FirebaseService firebaseService;
  // final String uid;
  final String? lastText;

  const TextEditorPage({
    super.key,
    // required this.firebaseService,
    // required this.uid,
    this.lastText,
  });

  @override
  _TextEditorPageState createState() => _TextEditorPageState(); //deleted uid: uid
}

class _TextEditorPageState extends State<TextEditorPage> {
  late FirebaseService firebaseService;//get in Provider.of in didChangeDependencies()
  late AppState appState;
  late User? user; // If User can be null, it should be nullable User?, but in this page it cannot be null but maybe can if just using without firebase
  late String _uid; // Mark _uid as late since it's guaranteed to be initialized in didChangeDependencies
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final TextEditingController _searchController =
      TextEditingController(); //>to>move>to>SearchReplaceFields
  final TextEditingController _replaceController =
      TextEditingController(); //>to>move>to>SearchReplaceFields
  // bool moreThanOneDeviceConnected = false;  
  String _previousReplaceText =
      ''; //  to store the previous replace text to allow reset of replace count
  bool _showSearchReplaceFields = false;
  final bool _showSettingsFields = false;
  double textFieldHeightAdjustment = 0.0;
  //for search----------------*moved to class SearchReplaceFields
  List<String> _searchHistory = [];
  int _foundItemCount = 0;
  int _replacedItemCount = 0;
  List<int> _foundIndices = [];
  int currentIndex = 0;
  // For saving regularly
  Timer? _firebaseSaveTimer; // Timer for saving to Firebase periodically
  bool _hasTextChanges =
      false; // Track if text has changed since last Firebase save
  // _TextEditorPageState(); // default constructor not necessary and initialization being done in initState and didChangeDependencies
  @override
  void initState() {
    super.initState();
    // Initialize with text from AppState or any other initialization.
    _loadSearchHistory(); //moved to searchreplacefields class
    _loadText();
    // Start a timer that triggers the save to Firebase every five
    _searchController
        .addListener(_onSearchTextChanged); // to allow seach as you type
    if (widget.lastText != null) {
      _textController.text = widget.lastText!;
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe to call Provider.of here because context is generically available in didChangeDependencies
    firebaseService = Provider.of<FirebaseService>(context, listen: false);
    appState = Provider.of<AppState>(context);
    // user = appState.user; // the Firebase User, only needed for the user icon in appbar, could limit it to the icon or just get rid of if we want to emp privacy 
    if (appState.user != null) {
      user = appState.user!;
      _uid = appState.user!.uid; // Directly access the UID from appState.user
      //_uid = user.uid; // Now you can safely initialize _uid with the user's UID
    } else {
      _uid = "uid_for_local_saving_only";
    }
    startFirebaseSaveTimer(); // Call the method after _uid is initialized
  }
  void startFirebaseSaveTimer() {
    _firebaseSaveTimer?.cancel(); // Cancel the previous timer if it exists
    // Start a new periodic timer
    _firebaseSaveTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_hasTextChanges) {
        firebaseService.saveTextToFirestore(_textController.text,
            _uid); // Save text to Firebase (or Firestore, as needed)
        _hasTextChanges = false;
      }
    });
  }
  void _toggleSearchReplaceFieldsVisibility() {
    setState(() {
      _showSearchReplaceFields = !_showSearchReplaceFields;
    });
  }

  //____________SEARCH REPLACE FUNCTIONS THAT WERE ONCE IN A CLASS OF THEIR OWN_______________
  void goToNextInstance() {
    // if (_foundItemCount == 0) {
    //   _performSearch();
    // }
    print('>>>___ currentIndex $currentIndex');
    if (_foundIndices.isNotEmpty) {
      currentIndex = (currentIndex + 1) % _foundIndices.length;
      //modulo operator % used to reset currentIndex to 0 when it reaches _foundIndices.length
      int position = _foundIndices[currentIndex];
      // Remove focus from the TextField. Neccessary to get focus the second time
      _textFieldFocusNode.unfocus();
      Future.delayed(const Duration(milliseconds: 30), () {
        //delays allows unfocus to take effect so the enxt work can be focused correctly, if does not work, chang to 50 to 100ms
        _textFieldFocusNode.requestFocus();
      });
      // _textFieldFocusNode.requestFocus(); //<- this onl work first time>
      _textController.selection = TextSelection(
        baseOffset: position,
        extentOffset: position + _searchController.text.length,
      );
    }
  }
  void goToPreviousInstance() {
    if (_foundIndices.isNotEmpty) {
      currentIndex =
          (currentIndex - 1 + _foundIndices.length) % _foundIndices.length;
      int position = _foundIndices[currentIndex];
      _textFieldFocusNode.unfocus();
      Future.delayed(const Duration(milliseconds: 30), () {
        _textFieldFocusNode.requestFocus();
      });

      _textController.selection = TextSelection(
        baseOffset: position,
        extentOffset: position + _searchController.text.length,
      );
    }
  }
  void _performSearch() {
    String searchTerm = _searchController.text;
    String text = _textController.text;
    List<int> foundIndices = [];
    int index = 0;
    if (searchTerm.isNotEmpty) {
      //to avoid infinite search loop
      while (index != -1) {
        index = text.indexOf(
            searchTerm, index); // .indexOf returns -1 if nothing found
        if (index != -1) {
          foundIndices.add(index); //adds location of the current search term
          index += searchTerm.length; //start search again after the search term
        }
      }
    }
    // Update the found item count and the text controller's selection
    //###test--issue not here###
    setState(() {
      _foundItemCount = foundIndices.length;
    });

    _foundIndices =
        foundIndices; // Store the found indices and substrings in the state variables

    _addToSearchHistory(searchTerm); // Add the search term to the history
  }
  void _performReplace() {
    String searchTerm = _searchController.text;
    String replaceTerm = _replaceController.text;
    String text = _textController.text;
    // Perform the replace operation
    TextSelection selection = _textController.selection;
    int startIndex = selection.start;
    int endIndex = selection.end;
    String selectedText = text.substring(startIndex, endIndex);
    String newText = text.replaceRange(startIndex, endIndex, replaceTerm);
    // Update the text controller with the replaced text
    _textController.text = newText;
    // Update the replaced item count

    // Update the found indices and substrings if necessary
    if (_foundIndices.isNotEmpty) {
      // setState(() {
      //   _replacedItemCount++;
      // });
      for (int i = 0; i < _foundIndices.length; i++) {
        int index = _foundIndices[i];
        if (index >= endIndex) {
          _foundIndices[i] += replaceTerm.length - selectedText.length;
        }
      }
      // for (int i = 0; i < foundSubstrings.length; i++) {
      //   String substring = foundSubstrings[i];
      //   if (i < foundSubstrings.length - 1 &&
      //       substring.contains(selectedText)) {
      //     foundSubstrings[i] =
      //         substring.replaceFirst(selectedText, replaceTerm);
      //   }
      // }
    }
    goToNextInstance();
    // Add the search term to the history
    _addToSearchHistory(searchTerm);
    // Update the search and replace count if the replace text has changed
    if (_previousReplaceText != replaceTerm) {
      setState(() {
        _replacedItemCount =
            1; // Reset the replace count to 1 for the new replace term.
      });
    } else {
      setState(() {
        _replacedItemCount++; // Increment the replace count for the same replace term.
      });
    }
    // Store the current replace term as the previous replace text for the next comparison
    _previousReplaceText = replaceTerm;
    // Perform the search to find the updated occurrences of the search term with the new replace term
    _performSearch();
  }
  void _performReplaceAll() {
    if (_textController.text.isNotEmpty) {
      // Save a backup
      String searchTerm = _searchController.text;
      String replaceTerm = _replaceController.text;
      String text = _textController.text;
      print(">>before replace all>>save to cloud clicked");
      firebaseService.saveTextToFirestore(_textController.text, _uid);

      // Perform the replace operation
      String newText = text.replaceAll(searchTerm, replaceTerm);

      // Update the text controller with the replaced text
      _textController.text = newText;

      // Calculate the number of replacements and add to _replacedItemCount
      int numReplacements = (text.length - newText.length) ~/ searchTerm.length;
      setState(() {
        _replacedItemCount += numReplacements;
      });
      // Perform the search to find the updated occurrences of the search term with the new replace term
      _performSearch();
      // Add the search term to the history
      _addToSearchHistory(searchTerm);
    }
  }
  void _onSearchTextChanged() {
    // Perform the search whenever the text changes
    _performSearch();
  }
  void _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }
  void _saveSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('searchHistory', _searchHistory);
  }
  void _addToSearchHistory(String searchTerm) {
    if (!_searchHistory.contains(searchTerm)) {
      setState(() {
        _searchHistory.add(searchTerm);
      });
      _saveSearchHistory();
    }
  }
  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
    _saveSearchHistory();
  }
  //____________TO HERE SEARCH REPLACE FUNCTIONS THAT WERE ONCE IN A CLASS OF THEIR OWN_______________
  //~~~~~~~~~~~~~~~~~~~Text loading, saving functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _loadText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedText = prefs.getString('savedText');
    setState(() {
      _textController.text = savedText ?? "";// Assign an empty string if savedText is null
    });
    }
 // Function to save text locally on the phone using SharedPreferences
  void saveTextLocally(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('localTextSaveOnAbruptExit', text);
  }
  void _saveTextLocally() async {
    String text = _textController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('savedText', text);
    print('>>>__ saved ${text.substring(0, 30)}');
  }
  void _handleTextChanges(String newText) {
    //to save text regularly
    setState(() {
      _hasTextChanges = true; // Set the flag to true when text changes
    });
    _saveTextLocally(); // Save to SharedPreferences immediately on text change
  }
  //End~~~~~~~~~~~~~~~~~~~Text loading, saving functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//already have user, so do we need next lines?
  // Future<void> _getUser() async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   setState(() {
  //     _user = user;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    double textFieldHeight = MediaQuery.of(context).size.height -
        (kIsWeb ? 80.0 : 360.0); //adjust to height of keyboard when it pops up
    if (_showSearchReplaceFields) {
      textFieldHeight -= 60.0; //adjust to height of find replace fields
    }
 
    return Scaffold(
      resizeToAvoidBottomInset:
        false, //set to false to reset when keyboard pops up
      appBar: AppBar(
        title: const Text("TE"),//Text Editor
        actions: <Widget>[
          //find icon with subscript as # found
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    // _searchController.text = '';
                    // _replaceController.text = '';
                    _showSearchReplaceFields
                        ? _showSearchReplaceFields = false
                        : _showSearchReplaceFields = true;
                    // _addToSearchHistory(_searchController.text);
                  });
                },
              ),
            ],
          ),
          //settings-move to drawer
          //Icons.timer
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () {
              print(">>appbar>>timestamp clicked");
              _setTimestampToClipboard(context);
              _pasteFromClipboard(); // at cursor or end if cursor not in field
            },
          ),
          //_copyToClipboard()-no need now (use generic action)
          //_pasteFromClipboard()-no need now (use generic action)
          //.saveTextToFirestore - do more automatically
          //todo>> make stack show deviceCount number of add file saving saving change functionality
          // dont need button here to exit app
          if (user != null) //user icon
            CircleAvatar(
              backgroundImage: NetworkImage(user!.photoURL ?? ''),
            ),
          // Include other AppBar actions or icons as needed
        ],
      ),
      body: Column(
        children: <Widget>[
          Visibility(
            visible: _showSearchReplaceFields,
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Find',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: _replaceController,
                  decoration: const InputDecoration(
                    labelText: 'Replace with',
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => _findText(), // Implement find text functionality
                      child: const Text('Find'),
                    ),
                    ElevatedButton(
                      onPressed: () => _replaceText(), // Implement replace text functionality
                      child: const Text('Replace'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _textFieldFocusNode,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: "Enter your text here",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _findText() {
    // Implement find text functionality
  }

  void _replaceText() {
    // Implement replace text functionality
  }
  void _setTimestampToClipboard(BuildContext context) {
    //context necessary to get local date from up the widget tree
    DateTime now = DateTime.now();
    String locale = Localizations.localeOf(context).toLanguageTag();
    String formattedDate = DateFormat.yMd(locale)
        .add_jms()
        .format(now); //using devices local format
    //    String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    Clipboard.setData(ClipboardData(text: formattedDate));
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final String pastedText = data?.text ?? '';
    final textSelection = _textController.selection;
    final newText = _textController.text.replaceRange(
      textSelection.start,
      textSelection.end,
      pastedText,
    );
    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(
        offset: textSelection.start + pastedText.length);
  }
  void _getLastSavedText() async {
    String? lastSavedText = await firebaseService.getLastSavedText(_uid);
    setState(() {
      _textController.text = lastSavedText ?? ""; // Assign an empty string if lastSavedText is null

    });
  } // puts text from firebase to the text box
  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    _replaceController.dispose();
    _textFieldFocusNode.dispose();
        String textToSave = _textController.text;
    _firebaseSaveTimer
        ?.cancel(); // Cancel the timer when the widget is disposed
    // saveTextLocally(textToSave);
    // Save the text to Firebase Firestore
    firebaseService.saveTextToFirestore(_textController.text, _uid);
    super.dispose();
  }
}
