// lib/src/web_storage_web.dart
import 'dart:html' as html;

/// Web-only implementations
String? getLocalStorage(String key) => html.window.localStorage[key];

void setLocalStorage(String key, String value) {
  html.window.localStorage[key] = value;
}

void downloadFile(String content, String filename, String mimeType) {
  final blob = html.Blob([content], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
