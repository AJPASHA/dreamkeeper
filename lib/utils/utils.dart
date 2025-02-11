// General utility functions


import 'package:flutter/material.dart';



final nonWhitespacePattern = RegExp(r"\S");
// Utilities for platform specific adaptations 
/// Identify if build platform is mobile
bool contextIsMobile(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS || 
         Theme.of(context).platform == TargetPlatform.android;
}
