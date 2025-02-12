import 'package:dreamkeeper/style/text_styles.dart';
import 'package:dreamkeeper/utils/utils.dart';
import 'package:flutter/material.dart';
// Import Page widgets for the nav bar
import 'package:dreamkeeper/widgets/feeds_list/feeds_list.dart';
import 'package:dreamkeeper/widgets/search/search.dart';
import 'package:dreamkeeper/widgets/tab_switcher/tabs.dart';

/// index.dart
///
/// The Home page of the app
/// A navigation bar which is able to render widgets related to the core functionalities
/// Can display contents relating to file browsing, searching for notes and the editor
/// Access: Public
///
class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  static const double iconSize = 42.0;
  Widget _currentView = Search();

  @override
  Widget build(BuildContext context) {
    // The List of buttons in the nav bar
    final List<Widget> destinations = [
      feedsButton(),
      searchButton(),
      tabsButton(),
    ];
    // The list
    final isMobile = contextIsMobile(context);

    // Navigator.of(context).pushNamed()
    return Scaffold(
      body: SafeArea(child: _currentView),
      appBar: isMobile
          ? AppBar(
              title: Text(
              "dreamkeeper",
              style: h1,
            ))
          : AppBar(
              title: Text("dreamkeeper"),
              actions: destinations,
            ),
      bottomNavigationBar: !isMobile
          ? null
          : BottomAppBar(
              child: Row(
                children: destinations.map((e) => Expanded(child: e)).toList(),
              ),
            ),
    );
  }

  IconButton feedsButton() {
    return IconButton(
      icon: const Icon(Icons.folder),
      iconSize: iconSize,
      color: (_currentView is FeedsList) ? Colors.blue : Colors.grey,
      onPressed: () => setState(() => _currentView = const FeedsList()),
    );
  }

  IconButton searchButton() {
    return IconButton(
      icon: const Icon(Icons.search),
      iconSize: iconSize,
      color: (_currentView is Search) ? Colors.blue : Colors.grey,
      onPressed: () => setState(() => _currentView = const Search()),
    );
  }

  IconButton tabsButton() {
    return IconButton(
      icon: const Icon(Icons.check_box_outline_blank),
      iconSize: iconSize,
      color: (_currentView is Tabs) ? Colors.blue : Colors.grey,
      onPressed: () => setState(() => _currentView = const Tabs()),
    );
  }
}
