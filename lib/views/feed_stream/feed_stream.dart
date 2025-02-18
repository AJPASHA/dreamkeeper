import 'components/document_card.dart';
import 'package:dreamkeeper/database/model.dart';
import 'package:dreamkeeper/main.dart';
import 'package:dreamkeeper/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:dreamkeeper/router.dart';

class FeedStream extends StatefulWidget {
  final Feed feed;
  const FeedStream({super.key, required this.feed});

  @override
  State<FeedStream> createState() => _FeedStreamState();
}

class _FeedStreamState extends State<FeedStream> {
  late final Feed feed;
  DocumentCard Function(BuildContext, int) _itemBuilder(List<FeedEntry> entries) {
    return (BuildContext context, int index) =>
        DocumentCard(entry: entries[index]);
  }
  @override
  void initState() {
    feed = widget.feed;
    // objectbox.getEntries(feed.id);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context,true);
            },
          ),
          title: Text(
            feed.title,
            style: h1,
          )),
      body: StreamBuilder(

          stream: objectbox.getEntries(feed.id),
          builder: (context, snapshot) {
            if (snapshot.data?.isNotEmpty ?? false) {
              return ListView.builder(
                  key: UniqueKey(),
                  shrinkWrap: true,
                  itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                  itemBuilder: _itemBuilder(snapshot.data ?? []));
            } else {
              return const Center(
                  child:
                      Text("Press the + icon to add documents to this feed"));
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/editor',
              arguments: EditorArgs(fromFeed: widget.feed));
          if(result == true) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
