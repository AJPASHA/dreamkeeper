
import 'package:flutter/material.dart';

/// The class for the file browser screen
/// 
class Browser extends StatelessWidget {
  const Browser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: Column(
        children: [
          Text("Browser Screen coming soon!"),
          IconButton(
            icon: Icon(Icons.edit), 
            onPressed: () => Navigator.pushNamed(context, '/editor')
          ),
        ],
      )
    );
  }
}