import 'dart:io';

void main() {
  Directory dir = Directory('e:/devpokit/clients/grocery/Grocery_user/lib/screens');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var text = file.readAsStringSync();
      var newText = text;
      
      // Handle imports
      if (!newText.contains('error_handler.dart') && (newText.contains("Text('Error") || newText.contains("Text(e.toString())"))) {
         newText = newText.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:grocery_user/utils/error_handler.dart';");
         if(newText == text) {
             newText = newText.replaceFirst("import 'package:provider/provider.dart';", "import 'package:provider/provider.dart';\nimport 'package:grocery_user/utils/error_handler.dart';");
         }
      }

      // Replacements
      newText = newText.replaceAll(
          RegExp(r"Text\('Error.*\$e'\)"),
          "Text(ErrorHandler.getFriendlyMessage(e))");
          
      newText = newText.replaceAll(
          RegExp(r"Text\('Error.*\$?\{?e.toString\(\)\}?'\)"),
          "Text(ErrorHandler.getFriendlyMessage(e))");
          
      newText = newText.replaceAll(
          RegExp(r"Text\(e.toString\(\)\)"),
          "Text(ErrorHandler.getFriendlyMessage(e))");

      if (text != newText) {
        file.writeAsStringSync(newText);
        print('Updated \${file.path}');
      }
    }
  }
}
