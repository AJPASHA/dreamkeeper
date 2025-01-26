import 'package:dreamkeeper/components/index/document_card.dart';
import 'package:dreamkeeper/database/model.dart';
import 'package:dreamkeeper/main.dart';
import 'package:dreamkeeper/style/text_styles.dart';
import 'package:flutter/material.dart';

class FeedStream extends StatefulWidget {
  final Feed feed;
  const FeedStream({super.key, required this.feed});

  @override
  State<FeedStream> createState() => _FeedStreamState();
}

class _FeedStreamState extends State<FeedStream> {

  DocumentCard Function(BuildContext, int) _itemBuilder(List<FeedEntry> entries) {
    return (BuildContext context, int index) => DocumentCard(entry: entries[index]);
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
          title: Text(
        widget.feed.title,
        style: h1,
      )),
      body: StreamBuilder(
        key: UniqueKey(),
        stream: objectbox.getEntries(widget.feed.id), 
        builder: (context, snapshot) {
          
          if (snapshot.data?.isNotEmpty ?? false) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.hasData ? snapshot.data!.length: 0,
              itemBuilder: _itemBuilder(snapshot.data ?? [])
            );
          } else {
            return const Center(child: Text("Press the + icon to add documents to this feed"));
          }
        }
      )
    );
  }
}
