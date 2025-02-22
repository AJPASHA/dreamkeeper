import 'package:dreamkeeper/database/model.dart';
import 'package:dreamkeeper/main.dart';
import 'package:flutter/material.dart';

class FeedPicker extends StatefulWidget {
  final DreamkeeperDocument document;
  
  const FeedPicker(this.document, {super.key});

  @override
  State<FeedPicker> createState() => _FeedPickerState();
}

class _FeedPickerState extends State<FeedPicker> {
  late DreamkeeperDocument _document;

  List<int> get documentFeeds => _document.feeds
      .map((e) => e.id).toList();

  bool docIsInFeed(int feedId) => documentFeeds.contains(feedId);


  @override
  Widget build(BuildContext context) {
    _document = objectbox.getDocument(widget.document.id)!; // get the document from the DB because that way it updates
    return Scaffold(
      appBar: AppBar(
        title: Text("Add ${_document.title ?? "Unnamed Document"} to feed"),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {});
            Navigator.pop(context, true);
          },
        )
      ),
      body: StreamBuilder(
        stream: objectbox.getFeeds(), 
        builder: (BuildContext context, AsyncSnapshot<List<Feed>> snapshot) {
          if (snapshot.data?.isNotEmpty ?? false) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.hasData ? snapshot.data!.length : 0,
              itemBuilder: (context, index) => Row(
                children: [
                  Checkbox(
                    value: docIsInFeed(snapshot.data![index].id), 
                    onChanged: (bool? newValue) => setState(() {
                      final feedId = snapshot.data![index].id;
                      if (newValue ?? false) {
                        objectbox.addDocumentToFeed(_document.id, feedId);
                      } else {
                        objectbox.removeDocumentFromFeed(_document.id, feedId);
                      }
                    }),
                  ),
                  Text(snapshot.data![index].title)
                ],
              ),
            );
          } else {
            return const Center(
              child: Text("Please add some new feeds using the feeds view "),
              // Should rarely appear in practice
            );
          }
        })
      
    );
  }
}