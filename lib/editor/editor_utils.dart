import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

/* Utilities for handling documents in flutter quill */

/// Get a document from json string
Document getDocumentFromString(String content) => Document.fromJson(jsonDecode(content));

/// get a string from a flutter quill document
String getStringFromDocument(Document document) => jsonEncode(document.toDelta().toJson());

