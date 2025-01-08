import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// The class for the Editor screen
///
class Editor extends StatelessWidget {
  Editor({super.key});

  final QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            QuillSimpleToolbar(
              controller: _controller,
              configurations: const QuillSimpleToolbarConfigurations(),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: QuillEditor.basic(
                  controller: _controller,
                  configurations: const QuillEditorConfigurations(),
                ),
              ),
            ),
          ],
        ));
  }

  void dispose() {
    _controller.dispose();
  }
}
