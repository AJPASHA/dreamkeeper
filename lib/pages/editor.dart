import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// The class for the Editor screen
///
class Editor extends StatelessWidget {
  const Editor({super.key});


  @override
  Widget build(BuildContext context) {
    final QuillController _controller = QuillController.basic();
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Text("Editor"),
            QuillSimpleToolbar(
              controller: _controller,
              configurations: const QuillSimpleToolbarConfigurations(),
            ),
            Expanded(
              child: QuillEditor.basic(
                controller: _controller,
                configurations: const QuillEditorConfigurations(),
              ),
            )
          ],
        ));
  }
}
