// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_quill/flutter_quill_internal.dart';
// import 'package:flutter_quill/quill_delta.dart';

// /// Applies italic format to text segment (which is surrounded by *)
// /// when user inserts space character after it.
// class AutoFormatItalicRule extends InsertRule {
//   const AutoFormatItalicRule();
//   static const _italicPattern = r'\*\S(.+\S)?\*';
//   // pattern looks for an asterisk followed by a non-whitespace character
//   // optionally it then picks up a sequence of other characters bounded by another asterisk
//   // providing that the last character is also not a whitespace character
//   RegExp get italicRegExp => RegExp(
//     _italicPattern,
//     caseSensitive: false,
//   );

//   @override
//   Delta? applyRule(
//     Document document,
//     int index, 
//     {
//       int? len,
//       Object? data,
//       Attribute? attribute,
//       Object? extraData,
//     }
//   ) {

//     // This rule only applies to strings
//     if (data is! String) return null;
//     // This rule only applies where an asterisk is being inserted 
//     if (data != '*') return null;
//     // Get current text.
//     final entireText = document.toPlainText();

//     // because document is prior to insertion and this rule works on a 'willSet' 
//     // basis, we need to synthesise a version of the amended document to 
//     // simplify the regex matching 
//     final futureText = entireText.substring(0, index) + data + entireText.substring(index);

//     // look for italic matches
//     final italicMatches = italicRegExp.allMatches(futureText);  

//     // look through matches and search for first where the substring either starts or ends on the insertion point
//     int? startIndex;
//     int? endIndex;

//     for (RegExpMatch match in italicMatches) {
//       if (match.start == index || match.end == index+1) {
//         startIndex = match.start;
//         endIndex = match.end;
//         break;
//       } 
//     } 

//     if (startIndex == null || endIndex == null) {
//       return null;
//     }
//     final baseDelta = document.toDelta();
//     // final prior = baseDelta.slice(0, startIndex);
//     // final updateSection = baseDelta.slice(startIndex+1, endIndex); // TODO, this needs to be adapted to 'listener' string length when we generalise
//     // final post = baseDelta.slice(endIndex);


//     Delta output = baseDelta..delete(count);
  
//     print(output);
//     return null;
//   }

// }


// //     // Build base delta.
// //     // The base delta is a simple insertion delta.
// //     final baseDelta = Delta()
// //       ..retain(index)
// //       ..insert(data);

// //     // Get unchanged text length.
// //     final unmodifiedLength = index - leftWordPart.length;

// //     // Create formatter delta.
// //     // The formatter delta will include italic formatting when needed.
// //     final formatterDelta = Delta()..retain(unmodifiedLength);

// //     var previousEndRelativeIndex = 0;

// //     void retainWithAttributes(int start, int end, Map<String, dynamic> attributes) {
// //       final separationLength = start - previousEndRelativeIndex;
// //       final segment = affectedWords.substring(start, end);
// //       formatterDelta
// //         ..retain(separationLength)
// //         ..retain(segment.length, attributes);
// //       previousEndRelativeIndex = end;
// //     }

// //     for (final match in italicMatches) {
// //       final matchStart = match.start;
// //       final matchEnd = match.end;

// //       retainWithAttributes(matchStart + 1, matchEnd - 1, const ItalicAttribute().toJson());
// //     }

// //     // Get remaining text length.
// //     final remainingLength = affectedWords.length - previousEndRelativeIndex;

// //     // Remove italic from remaining non-italic text.
// //     formatterDelta.retain(remainingLength);

// //     // Build resulting change delta.
// //     return baseDelta.compose(formatterDelta);
// //   }
// // }