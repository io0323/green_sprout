// lib/src/web_storage_stub.dart
/// Fallback for non-web platforms. Keep behavior safe for analyzer/CI.
/// You can replace with platform-appropriate storage later (shared_preferences, file system, etc).
String? getLocalStorage(String key) => null;

void setLocalStorage(String key, String value) {
  // No-op on non-web by default.
}

void downloadFile(String content, String filename, String mimeType) {
  // No-op or throw depending on desired behaviour. Keep no-op to avoid runtime error in non-web CI.
  // throw UnsupportedError('Download is not supported on this platform.');
}
