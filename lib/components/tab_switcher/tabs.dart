
import 'package:flutter/material.dart';

/// The class for the tabs screen
/// 
class Tabs extends StatelessWidget {
  const Tabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: Column(
        children: [
          Text("Tab Switcher Screen coming soon!"),
          Placeholder(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/editor'),
        child: const Icon(Icons.add),
      ),
    );
  }
}