// ignore_for_file: avoid_web_libraries_in_flutter
// lib/src/web_storage_web.dart
import 'dart:html' as html;

/// Web-only implementations
String? getLocalStorage(String key) => html.window.localStorage[key];

void setLocalStorage(String key, String value) {
  html.window.localStorage[key] = value;
}

void downloadFile(String content, String filename, String mimeType) {
  // Cast List<String> to List<dynamic> for Blob compatibility
  final blob = html.Blob([content] as List<dynamic>, mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
