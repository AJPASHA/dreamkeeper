import 'package:dreamkeeper/database/model.dart';
import 'package:dreamkeeper/style/text_styles.dart';
import 'package:flutter/material.dart';
import '../../sitemap.dart';


class DocumentCard extends StatefulWidget {
  final FeedEntry entry;
  const DocumentCard({super.key, required this.entry});

  @override
  State<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> {

  
  @override
  Widget build(BuildContext context) {
    final DreamkeeperDocument? document = widget.entry.document.target;

    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed('/editor', arguments: EditorArgs(widget.entry.document.target)),
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
          child: Text(document?.blocks.firstOrNull?.plaintext ?? "Unnamed Document", style: h2)
        ),
      ),
    );
  }
}