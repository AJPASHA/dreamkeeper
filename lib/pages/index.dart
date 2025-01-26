import 'package:dreamkeeper/style/text_styles.dart';
import 'package:dreamkeeper/utils/utils.dart';
import 'package:flutter/material.dart';
// Import Page widgets for the nav bar
import 'package:dreamkeeper/components/index/feeds_list.dart';
import 'package:dreamkeeper/components/index/search.dart';
import 'package:dreamkeeper/components/index/tabs.dart';

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
      browserButton(),
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

  IconButton browserButton() {
    return IconButton(
      icon: const Icon(Icons.folder),
      iconSize: iconSize,
      onPressed: () => setState(() => _currentView = const FeedsList()),
    );
  }

  IconButton searchButton() {
    return IconButton(
      icon: const Icon(Icons.search),
      iconSize: iconSize,
      onPressed: () => setState(() => _currentView = const Search()),
    );
  }

  IconButton tabsButton() {
    return IconButton(
      icon: const Icon(Icons.check_box_outline_blank),
      iconSize: iconSize,
      onPressed: () => setState(() => _currentView = const Tabs()),
    );
  }
}
