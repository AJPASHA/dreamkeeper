import 'package:dreamkeeper/database/model.dart';
import 'package:dreamkeeper/main.dart';
import 'package:dreamkeeper/router.dart';
import 'package:dreamkeeper/style/text_styles.dart';
import 'package:flutter/material.dart';

class SearchResults extends StatefulWidget {
  final String searchQuery;

  const SearchResults(this.searchQuery, {super.key});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  late final Future<List<DocumentBlock>> resultsList;

  @override
  void initState() {
    resultsList = objectbox.searchBlockVectors(widget.searchQuery);

    // resultsList = objectbox.searchBlockVectors(widget.searchQuery);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.searchQuery)),
      body: FutureBuilder(
          future: resultsList,
          builder: (BuildContext context,
              AsyncSnapshot<List<DocumentBlock>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  final DocumentBlock resultBlock = snapshot.data![index];
                  return ResultCard(resultBlock);
                },

              );
            } else if (snapshot.hasError) {
              debugPrint("${snapshot.error}");
              return Center(
                child: Text(
                    "Something has gone wrong with the search process, check your connection and then try again later"),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}

class ResultCard extends StatelessWidget {
  final DocumentBlock resultContent;
  const ResultCard(this.resultContent, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String? docTitle = resultContent.document.target?.blocks.first.plaintext; // Hmmm, this is long lol
    return GestureDetector(
      onTap: () async => await Navigator.of(context).pushNamed(
                        '/editor',
                        arguments: EditorArgs(document: resultContent.document.target)),
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 243, 243, 243),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 168, 168, 168),
                blurRadius: 5,
                offset: Offset(1, 2),
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(docTitle ?? "", style: h1,),
              Divider(),
              Text(resultContent.plaintext, style: h2),
            ],
          ),
        ),
      ),
    );
  }
}
