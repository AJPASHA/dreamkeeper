

import 'package:flutter/material.dart';
import '../../services/text_embedding_service.dart';

/// The class for the search bar screen
/// 
class Search extends StatefulWidget {
  const Search({super.key});
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEmbeddingService embeddingService = TextEmbeddingService();
  // TODO: remove from startup, this is just while we are developing and everything is moving aroudn a lot

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
              onSubmitted: (value) async {
                EmbeddingResponse? res = await embeddingService.getEmbeddings([controller.text], EmbeddingPassageType.query);
                debugPrint("${res?.embeddings[0]}");
              },
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