/**
 * WebストレージのWeb実装
 * Webプラットフォームで使用
 */
import 'dart:html' as html;

String? getLocalStorage(String key) {
  final storage = html.window.localStorage;
  return storage[key];
}

void setLocalStorage(String key, String value) {
  final storage = html.window.localStorage;
  storage[key] = value;
}

void downloadFile(String content, String filename, String mimeType) {
  final blob = html.Blob([content], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
