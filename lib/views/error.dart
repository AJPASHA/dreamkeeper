

import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("404 Page not found")),
      body: Center(
        child: Text("Sorry, page not found."),
      )
    );
  }
}