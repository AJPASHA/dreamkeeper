import 'package:dreamkeeper/database/model.dart';
import 'package:dreamkeeper/editor/editor_utils.dart';
import 'package:dreamkeeper/style/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../main.dart';

// TODO: Need to change the checkbox logic in flutter quill so that new line after checked box leads to unchecked box, not a checked box as in current behaviour

/// The class for the Editor screen
///
///
///

class Editor extends StatefulWidget {
  final DreamkeeperDocument dbDocument;
  const Editor({super.key, required this.dbDocument});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late final QuillController? _quillController;
  DateTime lastSaved = DateTime
      .now(); // we use this to reduce the frequency of autosaves to an acceptable level
  final double saveFrequency = 5000; // minimum number of ms before autosave

  @override
  void initState() {
    super.initState();
    final document = getDocumentFromString(widget.dbDocument.content);
    _quillController = QuillController(
        document: document,
        selection: TextSelection(baseOffset: 0, extentOffset: 0)); // TODO: change this to be able to take the starting point of a block.

    _quillController!.document.changes
        .listen((event) => handleEdit(event)); // listen for keystrokes
  }

  @override
  void dispose() {
      // TODO: Change this to work on the basis of quill controller plaintext
      if ((_quillController?.document.length ?? 0) == 1) {
        debugPrint("Deleting doc because empty");
        objectbox.deleteDocument(widget.dbDocument.id);
      } else {
        save(); 
      } 

    if (_quillController != null) {

      _quillController.dispose();
    }
    super.dispose();
  }

  void handleEdit(DocChange event) {
    final DateTime now = DateTime.now();

    if (now.difference(lastSaved).inMilliseconds > saveFrequency) {
      save();
    }
  }

  void save() {
    if (_quillController == null) {
      debugPrint("Cannot save, editor controller is not initialised yet");
    }

    DreamkeeperDocument saveDoc = widget.dbDocument;
    saveDoc.content = getStringFromDocument(_quillController!.document);
    //TODO: make it so that this also updates feed membership
    objectbox.saveDocument(saveDoc);
    lastSaved = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {});
              Navigator.pop(context, true);
            },
          ),
          title: Text(
            "Editor",
            style: h2,
          ),
        ),
        body: Column(
          children: [
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
