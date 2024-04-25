//module:  messaging_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class MessagingPage extends StatefulWidget {
  const MessagingPage({Key? key}) : super(key: key);

  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isMessagesPaused = false;

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
        actions: [
          IconButton(
            icon: Icon(_isMessagesPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              setState(() {
                _isMessagesPaused = !_isMessagesPaused;
                _isMessagesPaused ? appState.pauseMessages("roomId", "userId") : appState.unpauseMessages("roomId", "userId");
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: appState.textChatRooms.length, // Dummy count
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: appState.messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Align(
                    alignment: appState.messages[index]['senderId'] == "yourUserId" ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(appState.messages[index]['content']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      appState.sendMessage("roomId", _messageController.text, "userId");
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class MessagingPage extends StatelessWidget {
//   const MessagingPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Messaging')),
//       body: const Center(child: Text('Messaging Page Content')),
//     );
//   }
// }
