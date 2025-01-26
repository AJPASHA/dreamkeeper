import 'package:dreamkeeper/components/index/feed_card.dart';
import 'package:flutter/material.dart';
import '../../database/model.dart';
import '../../main.dart';
/// The class for the file browser screen
///
class FeedsList extends StatefulWidget {
  const FeedsList({super.key});

  @override
  State<FeedsList> createState() => _FeedsListState();
}

class _FeedsListState extends State<FeedsList> {
  FeedCard Function(BuildContext context, int) _itemBuilder(List<Feed> feeds) =>
      (BuildContext context, int index) => FeedCard(feed: feeds[index]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Feed>>(
          key:UniqueKey(),
          stream: objectbox.getFeeds(),
          builder: (context, snapshot) {
            if (snapshot.data?.isNotEmpty ?? false) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                  itemBuilder: _itemBuilder(snapshot.data ?? []));
            } else {
              return const Center(
                child: Text("Press + button to add a new feed"),
              );
            }
          }),
    );
  }
}
