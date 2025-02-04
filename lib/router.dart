import 'package:dreamkeeper/database/model.dart';
import 'package:dreamkeeper/pages/editor.dart';
import 'components/feed_stream/feed_stream.dart';
import 'package:flutter/material.dart';
import 'pages/error.dart';
import 'package:dreamkeeper/pages/index.dart';

/// This is a class which defines the 'sitemap' of the app
/// This allows us to define dynamic routing for various pages with
/// a DRY approach to setting things like access gating and
class Sitemap {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => Index());
      case '/editor':
        if (args is EditorArgs) {
          
          // either take the document from the caller or create a new document
          DreamkeeperDocument document = args.document ??
              DreamkeeperDocument("",
                  createdOn: DateTime.now(), editedOn: DateTime.now());


          if (args.fromFeed != null) { // if this route is being called from a feed, we need to create a new feed entry for the new document 
            final FeedEntry entry = FeedEntry();
            entry.feed.target = args.fromFeed;
            document.entries.add(entry);
          }

          return MaterialPageRoute(
              builder: (context) => Editor(
                    dbDocument: document,
                  ));
        }
        return MaterialPageRoute(
            builder: (context) => Editor(
                  dbDocument: DreamkeeperDocument("", createdOn: DateTime.now(), editedOn: DateTime.now()),
                ));
      case '/feed':
        if (args is FeedArgs) {
          return MaterialPageRoute(
              builder: (context) => FeedStream(feed: args.feed));
        } else {
          return MaterialPageRoute(builder: (context) => ErrorPage());
        }
      // case '/settings':
      //   return MaterialPageRoute(builder: (context) => Settings());
      // case '/sign-up':
      //   return MaterialPageRoute(builder: (context) => SignUp());
      // case '/sign-in':
      //   return MaterialPageRoute(builder: (context) => SignIn());
      default:
        return MaterialPageRoute(builder: (context) => ErrorPage());
    }
  }
}

class FeedArgs {
  final Feed feed;
  FeedArgs(this.feed);
}

class EditorArgs {
  final DreamkeeperDocument? document;
  final Feed? fromFeed;
  EditorArgs({this.document, this.fromFeed});
}
