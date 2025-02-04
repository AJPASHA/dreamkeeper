

import 'package:flutter/material.dart';

/// The class for the search bar screen
/// 
class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: Center(
        child: SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16.0)),
              onTap: (){},
              onChanged:(_){},
              onSubmitted: (value)=> debugPrint(value),
              leading: const Icon(Icons.search),
              
            );
          }, 
          suggestionsBuilder: (BuildContext context, SearchController controller) {
            return List<ListTile>.generate(5, (int index) {
              final String item = 'item $index';
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() => controller.closeView(item));
                },
              );
            });
          },
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/editor'),
        child: const Icon(Icons.add),
      ),
    );
  }
}