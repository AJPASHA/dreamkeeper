import 'package:dreamkeeper/database/model.dart';
import 'package:dreamkeeper/main.dart';
import 'package:dreamkeeper/router.dart';
import 'package:dreamkeeper/style/text_styles.dart';
import 'package:flutter/material.dart';
import '../shared/popup_menu_element.dart';


class FeedCard extends StatefulWidget {
  final Feed feed;
  const FeedCard({super.key, required this.feed});

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  final TextEditingController renameTextController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    // setState(() {
    //   renameTextController.text = widget.feed.title;
    // }); // so that when we rename the feed, the current name is already there

    return Container(
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
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context)
                    .pushNamed('/feed', arguments: FeedArgs(widget.feed)),
                child: Text(widget.feed.title, style: h2),
              ),
            ),
            PopupMenuButton<PopupMenuElement>(
              onSelected: (item) => onPopupSelected(context, item.text),
              itemBuilder: (BuildContext context) =>
                  [...PopupMenuItems.items.map(buildItem)],
            )
          ],
        ),
      ),
    );
  }

  PopupMenuItem<PopupMenuElement> buildItem(PopupMenuElement item) =>
      PopupMenuItem<PopupMenuElement>(value: item, child: Text(item.text));

  void onPopupSelected(BuildContext context, String item) {
    switch (item) {
      case 'delete':
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                    "Are you sure you want to delete the ${widget.feed.title} feed? This action cannot be undone."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Go Back")),
                  TextButton(
                      onPressed: () {
                        objectbox.feedBox.remove(widget.feed.id);
                        debugPrint("Feed ${widget.feed.title} deleted");
                        Navigator.of(context).pop();
                      },
                      child: Text("Confirm")),
                ],
              );
            });
      case 'rename':
        setState(() {
          renameTextController.text = widget.feed.title;
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Rename Feed to"),
                content: TextField(
                  controller: renameTextController,
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Nevermind")),
                  TextButton(
                    onPressed: () {
                      final feedToPut = widget.feed;
                      feedToPut.title = renameTextController.text;
                      objectbox.feedBox.put(feedToPut);
                      Navigator.of(context).pop();                      
                    },
                    child: Text("Rename"),
                  )
                ],
              );
            });
    }
  }

  void onRenameSelected(BuildContext context, Feed feed) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Renaming ${feed.title} to"),
            content: TextField(),
          );
        });
  }
}


class PopupMenuItems {
  static const delete = PopupMenuElement(text: "delete");
  static const rename = PopupMenuElement(text: "rename");
  static const List<PopupMenuElement> items = [delete, rename];
}

// class FeedsList extends StatelessWidget {
//   const FeedsList({super.key});


// }


