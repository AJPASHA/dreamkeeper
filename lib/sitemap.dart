import 'package:dreamkeeper/database/model.dart';
import 'package:dreamkeeper/pages/editor.dart';
import 'components/index/feed_stream.dart';
import 'package:flutter/material.dart';

import 'package:dreamkeeper/pages/index.dart';


/// This is a class which defines the 'sitemap' of the app
/// This allows us to define dynamic routing for various pages with
/// a DRY approach to setting things like access gating and 
class Sitemap {
  static Route<dynamic> generateRoute (RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => Index());
      case '/editor':
        if (args is EditorArgs){
          return MaterialPageRoute(builder: (context) => Editor(loadedDocument: args.document));
        }
        return MaterialPageRoute(builder: (context) => Editor());
      case '/feed':
        if (args is FeedArgs) {
          return MaterialPageRoute(builder: (context) => FeedStream(feed: args.feed));
        } else {
          //TODO: create an error page
          return MaterialPageRoute(builder: (context) => Index());
        }
      // case '/settings':
      //   return MaterialPageRoute(builder: (context) => Settings());
      // case '/sign-up':
      //   return MaterialPageRoute(builder: (context) => SignUp());
      // case '/sign-in':
      //   return MaterialPageRoute(builder: (context) => SignIn());
      default:
        return MaterialPageRoute(builder: (context) => Index()); // TODO: change this to a proper 404 page at some point
    }
  }
}

// ├─"/" // The navigation bar screen (redirects to /editor by default
// │ ├─ "/browser" // The Browser screen where we can look at feeds
// │ ├─ "/search" // the search screen
// │ ├─ "/editor" // the editor (can be fresh or with a specific file to load)
// │ ├─ "/tabs" // shows all of the open tabs
// │ ├─ "/feed" // The contents of a feed 
// ├─ "/settings" // settings screen
// ├─ "/sign-up"
// ├─ "/sign-in"


class FeedArgs {
  final Feed feed;
  FeedArgs(this.feed);
}

class EditorArgs {
  final DreamkeeperDocument? document;
  EditorArgs(this.document);
}