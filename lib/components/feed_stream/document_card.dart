import 'package:dreamkeeper/database/model.dart';
import 'package:dreamkeeper/style/text_styles.dart';
import 'package:flutter/material.dart';
import '../../router.dart';
import '../../main.dart';
import '../shared/popup_menu_element.dart';

class DocumentCard extends StatefulWidget {
  final FeedEntry entry;
  const DocumentCard({super.key, required this.entry});

  @override
  State<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> {
  // late FeedEntry entry;
  late DreamkeeperDocument? document;
  late String? title;

  @override
  void initState() {
    super.initState();
    document = widget.entry.document.target;
    title = document?.title;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => await Navigator.of(context).pushNamed('/editor',
          arguments: EditorArgs(document: document)),
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
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                      title ??
                          "Unnamed Document",
                      style: h2),
                ),
                PopupMenuButton<PopupMenuElement>(
                  onSelected: (item) => onPopupSelected(context, item.text),
                  itemBuilder: (BuildContext context) =>
                      [...PopupMenuItems.items.map(buildItem)],
                )
              ],
            )),
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
                    "Are you sure you want to delete $title? This action cannot be undone."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Go Back")),
                  TextButton(
                      onPressed: () {
                        if (document != null){
                          objectbox.deleteDocument(document!.id);
                          debugPrint("document deleted");
                        }

                        Navigator.of(context).pop();
                      },
                      child: Text("Confirm")),
                ],
              );
            });
    }
  }
}
class PopupMenuItems {
  static const delete = PopupMenuElement(text: "delete");
  static const List<PopupMenuElement> items = [delete];
}
