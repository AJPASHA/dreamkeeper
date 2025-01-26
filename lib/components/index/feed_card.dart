import 'package:dreamkeeper/database/model.dart';
import 'package:dreamkeeper/sitemap.dart';
import 'package:dreamkeeper/style/text_styles.dart';
import 'package:flutter/material.dart';

class FeedCard extends StatefulWidget {
  final Feed feed;
  const FeedCard({super.key, required this.feed});

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed('/feed', arguments: FeedArgs(widget.feed)),
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
          child: Text(widget.feed.title, style: h2)
        ),
      ),
    );
  }
}



// class FeedsList extends StatelessWidget {
//   const FeedsList({super.key});


// }


