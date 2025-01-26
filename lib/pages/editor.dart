import 'dart:convert';

import 'package:dreamkeeper/database/model.dart';
import 'package:dreamkeeper/editor/editor_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

// TODO: Need to change the checkbox logic in flutter quill so that new line after checked box leads to unchecked box, not a checked box as in current behaviour

/// The class for the Editor screen
///
///
///

class Editor extends StatefulWidget {
  final DreamkeeperDocument? loadedDocument;
  const Editor({super.key, this.loadedDocument});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late final QuillController? _quillController;

  @override
  void initState() {
    super.initState();
    if (widget.loadedDocument != null) {
      final document = getDocumentFromString(widget.loadedDocument!.content);
      _quillController = QuillController(document: document, selection: TextSelection(baseOffset: 0, extentOffset: 0));
    } else {
      _quillController = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _quillController!.dispose();
    super.dispose();
  }

  void saveDocument() {
    if (_quillController == null) {
      debugPrint("Cannot save, editor controller is not initialised yet");
    }

    String content = jsonEncode(_quillController!.document.toDelta().toJson()); // get the string content
    debugPrint(content);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Editor",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () => saveDocument(),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {},
                ),
              ],
            ),
            QuillSimpleToolbar(
              controller: _quillController,
              configurations:
                  const QuillSimpleToolbarConfigurations(), // edit this line to get rid of clutter, we are going to want to create some 'toolbar nav system here'
            ),
            Expanded(
              child: QuillEditor.basic(
                controller: _quillController,
                configurations: const QuillEditorConfigurations(),
                
              ),
            )
          ],
        ));
  }
}
