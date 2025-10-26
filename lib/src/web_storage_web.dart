// ignore_for_file: avoid_web_libraries_in_flutter
// lib/src/web_storage_web.dart
import 'package:web/web.dart' as web;

/// Web-only implementations
String? getLocalStorage(String key) => web.window.localStorage.getItem(key);

void setLocalStorage(String key, String value) {
  web.window.localStorage.setItem(key, value);
}

void downloadFile(String content, String filename, String mimeType) {
  final blob = web.Blob([content], web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
