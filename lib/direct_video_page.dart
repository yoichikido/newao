import 'package:flutter/material.dart';

class DirectVideoPage extends StatelessWidget {
  const DirectVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Video'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Action for settings
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Action for refresh
            },
          ),
        ],
      ),
      body: const Center(child: Text('Direct Video Content')),
    );
  }
}