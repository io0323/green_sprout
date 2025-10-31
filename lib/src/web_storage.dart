// Webストレージ機能のプラットフォーム選択ファイル
// Webプラットフォームではweb_storage_web.dartを、
// その他のプラットフォームではweb_storage_stub.dartを使用
export 'web_storage_stub.dart' if (dart.library.html) 'web_storage_web.dart';
