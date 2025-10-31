// Webストレージのスタブ実装
// モバイルプラットフォームで使用
String? getLocalStorage(String key) {
  // モバイルプラットフォームではローカルストレージをサポートしない
  return null;
}

void setLocalStorage(String key, String value) {
  // モバイルプラットフォームではローカルストレージをサポートしない
  // 何もしない
}

void downloadFile(String content, String filename, String mimeType) {
  // モバイルプラットフォームではダウンロード機能をサポートしない
  // 何もしない
}
