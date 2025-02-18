import 'components/feed_card.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
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
  final TextEditingController newFeedTitleController = TextEditingController();

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context, builder: (BuildContext context) {
            return NewFeedDialog(newFeedTitleController: newFeedTitleController);
          }
        ),
        child: Icon(Icons.feed),
      ),
    );
  }
}

class NewFeedDialog extends StatelessWidget {
  const NewFeedDialog({
    super.key,
    required this.newFeedTitleController,
  });

  final TextEditingController newFeedTitleController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add a new feed"),
      content: TextField(controller: newFeedTitleController),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), 
          child: Text("close")),
        TextButton(
          onPressed: () {
            try {
              objectbox.createFeed(newFeedTitleController.text);
              Navigator.of(context).pop();
            } on UniqueViolationException catch (_) {
              showDialog(
                context: context, 
                builder: (BuildContext context) {
                  return FeedAlreadyExistsDialog();
                }
              );
            }
          },
          child: Text("Save"),
        )
      ],
    );
  }
}

class FeedAlreadyExistsDialog extends StatelessWidget {
  const FeedAlreadyExistsDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("A feed with that name already exists, please come up with a new name"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Close")
        )
      ]
    );
  }
}
