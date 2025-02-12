import 'package:dreamkeeper/database/model.dart';
import 'package:dreamkeeper/utils/editor_utils.dart';
// import 'package:dreamkeeper/style/text_styles.dart';
import 'package:dreamkeeper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
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
  static const double saveFrequency = 5000; // minimum number of ms before autosave
  static const _toolbarConfig = QuillSimpleToolbarConfigurations(
    multiRowsDisplay: false,
    showFontFamily: false,
    showFontSize: false,
    showSearchButton: false // this one might get undone later on...

  );
  late final TextEditingController titleController;
  late final QuillController? _quillController;
  DateTime lastSaved = DateTime
      .now(); // we use this to reduce the frequency of autosaves to an acceptable level


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
        title: TextField(
          controller: titleController,
          onEditingComplete: () => save(),
          decoration: InputDecoration(
            hintText: widget.dbDocument.blocks.isEmpty ? "" : widget.dbDocument.blocks[0].plaintext,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintTextDirection: TextDirection.ltr,
            fillColor: Colors.transparent,
          ),
        )
      ),
      body: Column(
        children: [
          // Static editor toolbar for desktop applications 
          Visibility(
            visible: !contextIsMobile(context),
            child: QuillSimpleToolbar(controller: _quillController, configurations: _toolbarConfig)
          ),
          
          // a list of all the feeds that this is a part of 
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              runSpacing: 8,
              spacing: 8,
              children: widget.dbDocument.entries.map((entry) {
                return ActionChip(
                  label: Text(entry.feed.target?.title ?? ""),
                  onPressed: () => Navigator.of(context).pushNamed('/'), // TODO: Make this an actual route with args
                  // TODO: add an extension to allow long presses
                );
              }).toList() + [const ActionChip(
                avatar: Icon(Icons.add),
                label: Text("add to feed..."),
              )],
            ),
          ),
          // The editor itself
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 20, 0),
              child: QuillEditor.basic(
                controller: _quillController,
                configurations: const QuillEditorConfigurations(),
              ),
            ),
          ),
          // This defines the floating keyboard bar found on iOS
          KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
            return Visibility(
                visible: isKeyboardVisible,
                child: Row(
                  children: [
                    Expanded(
                      child: SafeArea(
                          top: false,
                          child: QuillSimpleToolbar(
                            controller: _quillController,
                            configurations: _toolbarConfig,
                        )
                      ),
                    ),
                    IconButton(onPressed: () => FocusScope.of(context).unfocus(), icon: Icon(Icons.keyboard_arrow_down))
                  ],
                )
                );
          })
        ],
      ),
    );
  }
  void handleEdit(DocChange event) {
    final DateTime now = DateTime.now();

    if (now.difference(lastSaved).inMilliseconds > saveFrequency) {
      save();
    }
  }


  @override
  void initState() {
    super.initState();
    final document = getDocumentFromString(widget.dbDocument.content);
    titleController = TextEditingController(text: widget.dbDocument.title);
    _quillController = QuillController(
        document: document,
        selection: TextSelection(
            baseOffset: 0,
            extentOffset:
                0)); // TODO: change this to be able to take the starting point of a block.

    _quillController!.document.changes
        .listen((event) => handleEdit(event)); // listen for keystrokes
  }

  @override
  void dispose() {
    // TODO: Change this to work on the basis of quill controller plaintext
    if (!nonWhitespacePattern.hasMatch(_quillController?.document.toPlainText() ?? " "))  {
      debugPrint("Deleting doc because empty");
      objectbox.deleteDocument(widget.dbDocument.id);
    } else {
      save();
    }

    if (_quillController != null) {
      _quillController.dispose();
    }
    titleController.dispose();
    super.dispose();
  }
  void save() {
    if (_quillController == null) {
      debugPrint("Cannot save, editor controller is not initialised yet");
      return;
    }
    final document = _quillController.document;

    if (!nonWhitespacePattern.hasMatch(document.toPlainText())) { // don't save a document if there are only whitespace chars in it
      return;
    }
    widget.dbDocument.content = getStringFromDocument(document);
    widget.dbDocument.title = titleController.text == "" ? null : titleController.text;

    //TODO: make it so that this also updates feed membership
    objectbox.saveDocument(widget.dbDocument);
    lastSaved = DateTime.now();
  }
}
