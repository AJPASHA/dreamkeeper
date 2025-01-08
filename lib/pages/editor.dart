import 'package:flutter/material.dart';

/// The class for the Editor screen
/// 
class Editor extends StatelessWidget {
  const Editor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(),
      body: Column(
        children: [
          Text("Editor Screen coming soon!"),
          Placeholder(),
        ],
      )
    );
  }
}