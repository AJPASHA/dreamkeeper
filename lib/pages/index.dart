import 'package:dreamkeeper/utils/utils.dart';
import 'package:flutter/material.dart';
// Import Page widgets for the nav bar
import 'package:dreamkeeper/pages/index/browser.dart';
import 'package:dreamkeeper/pages/index/search.dart';
import 'package:dreamkeeper/pages/index/tabs.dart';
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
  Widget _currentView = Search();


  @override
  Widget build(BuildContext context) {

    // The List of buttons in the nav bar
    final List<IconButton> destinations = [
      _buildBrowserButton(), 
      _buildSearchButton(),
      _buildTabsButton(),
    ];
    // The list
    final isMobile = contextIsMobile(context);

    // Navigator.of(context).pushNamed()
    return Scaffold(
      body: SafeArea(child: _currentView),
      appBar: isMobile ? null : AppBar(
        actions: destinations,
      ),
      bottomNavigationBar: !isMobile ? null : BottomAppBar(
        child: Row(
          children: destinations,
        ),
      ),
    );
  }


  IconButton _buildBrowserButton() {
    return IconButton(
      icon: const Icon(Icons.folder),
      onPressed: () => setState(() => _currentView= const Browser()),
    );
  }

  IconButton _buildSearchButton() {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: () => setState(() => _currentView= const Search()),
    );
  }
  IconButton _buildTabsButton() {
    return IconButton(
      icon: const Icon(Icons.square),
      onPressed: () => setState(() => _currentView= const Tabs()),
    );
  }
}

