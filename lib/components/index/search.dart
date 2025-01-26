

import 'package:flutter/material.dart';

/// The class for the search bar screen
/// 
class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: Column(
        children: [
          Text("Search Screen coming soon!"),
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