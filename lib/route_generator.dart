// import 'package:flutter/material.dart';

// import 'package:dreamkeeper/pages/index/index.dart';
// import 'package:dreamkeeper/pages/settings.dart';
// import 

/// This is a class containing a route generator that allows for dynamic 
/// routing in a single place, which allows us to pass data between pages 
/// from a single location
// class RouteGenerator {
//   static Route<dynamic> generateRoute (RouteSettings settings) {
//     final args = settings.arguments;

//     switch (settings.name) {
//       case '/':
//         return MaterialPageRoute(builder: (context) => Index());
//       case '/settings':
//         return MaterialPageRoute(builder: (context) => Settings());
//       case '/sign-up':
//         return MaterialPageRoute(builder: (context) => SignUp());
//       case '/sign-in':
//         return MaterialPageRoute(builder: (context) => SignIn());
//       default:
//         return MaterialPageRoute(builder: (context) => ErrorPage());
//     }
//   }
// }

// ├─"/" // The navigation bar screen (redirects to /editor by default
// │ ├─ "/browser" // The Browser screen where we can look at feeds
// │ ├─ "/search" // the search screen
// │ ├─ "/editor" // the editor (can be fresh or with a specific file to load)
// │ ├─ "/tabs" // shows all of the open tabs
// │ ├─ "/feed" // The contents of a feed 
// ├─ "/settings" // settings screen
// ├─ "/sign-up"
// ├─ "/sign-in"
