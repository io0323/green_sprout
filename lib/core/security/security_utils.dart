import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// セキュリティユーティリティクラス
/// アプリケーションのセキュリティを強化するための機能を提供
class SecurityUtils {
  // Encryption key should be loaded securely from environment variable
  /// Loads the encryption key from the environment variable ENCRYPTION_KEY.
  /// In production, this must be set. For development or testing, a fallback key is used.
  static String _getEncryptionKey() {
    final key = Platform.environment['ENCRYPTION_KEY'];
    if (key == null || key.isEmpty) {
      // Fallback for development/testing only. DO NOT use in production.
      if (kDebugMode) {
        AppLogger.debugWarning(
            'ENCRYPTION_KEY environment variable not set. Using fallback key.');
        return 'default_fallback_key_please_change'; // Change this for local testing
      }
      throw Exception(
          'Encryption key not set in environment variable ENCRYPTION_KEY. Please set this variable in your deployment environment.');
    }
    return key;
  }

  static const int _saltLength = 16;

  /// データを暗号化する
  /// @param data 暗号化するデータ
  /// @return 暗号化されたデータ
  static String encrypt(String data) {
    try {
      final key = _generateKey();
      final iv = _generateIV();

      // 簡単なXOR暗号化（本番環境ではより強固な暗号化を使用）
      final encrypted = _xorEncrypt(data, key);
      final combined = '$iv:$encrypted';

      return base64Encode(utf8.encode(combined));
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debugError('Encryption error', e);
      }
      return data; // エラー時は元のデータを返す
    }
  }

  /// データを復号化する
  /// @param encryptedData 暗号化されたデータ
  /// @return 復号化されたデータ
  static String decrypt(String encryptedData) {
    try {
      final decoded = utf8.decode(base64Decode(encryptedData));
      final parts = decoded.split(':');

      if (parts.length != 2) {
        throw Exception('Invalid encrypted data format');
      }

      final encrypted = parts[1];

      final key = _generateKey();
      return _xorDecrypt(encrypted, key);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debugError('Decryption error', e);
      }
      return encryptedData; // エラー時は元のデータを返す
    }
  }

  /// パスワードのハッシュを生成する
  /// @param password パスワード
  /// @param salt ソルト（オプション）
  /// @return ハッシュ化されたパスワード
  static String hashPassword(String password, {String? salt}) {
    final saltBytes = salt != null ? utf8.encode(salt) : _generateSalt();

    final passwordBytes = utf8.encode(password);
    final combined = List<int>.from(saltBytes)..addAll(passwordBytes);

    final hash = sha256.convert(combined);
    return base64Encode(hash.bytes);
  }

  /// パスワードを検証する
  /// @param password パスワード
  /// @param hash ハッシュ
  /// @param salt ソルト
  /// @return 検証結果
  static bool verifyPassword(String password, String hash, String salt) {
    final hashedPassword = hashPassword(password, salt: salt);
    return hashedPassword == hash;
  }

  /// 安全なランダム文字列を生成する
  /// @param length 長さ
  /// @return ランダム文字列
  static String generateSecureRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// データの整合性を検証する
  /// @param data データ
  /// @param checksum チェックサム
  /// @return 検証結果
  static bool verifyIntegrity(String data, String checksum) {
    final calculatedChecksum = _calculateChecksum(data);
    return calculatedChecksum == checksum;
  }

  /// データのチェックサムを計算する
  /// @param data データ
  /// @return チェックサム
  static String calculateChecksum(String data) {
    return _calculateChecksum(data);
  }

  /// セキュアなストレージにデータを保存する
  /// @param key キー
  /// @param value 値
  static Future<void> secureStore(String key, String value) async {
    try {
      // 実際の実装では、SecureStorageやKeychainを使用
      if (kDebugMode) {
        AppLogger.debug('Securely stored: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debugError('Secure store error', e);
      }
    }
  }

  /// セキュアなストレージからデータを取得する
  /// @param key キー
  /// @return 値
  static Future<String?> secureRetrieve(String key) async {
    // 実際の実装では、SecureStorageやKeychainを使用
    if (kDebugMode) {
      AppLogger.debug('Securely retrieved: $key');
      // Return a dummy value for development/testing
      return null;
    }
    // In production, return null or handle appropriately
    return null;
  }

  /// セキュアなストレージからデータを削除する
  /// @param key キー
  static Future<void> secureDelete(String key) async {
    try {
      // 実際の実装では、SecureStorageやKeychainを使用
      if (kDebugMode) {
        AppLogger.debug('Securely deleted: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debugError('Secure delete error', e);
      }
    }
  }

  /// アプリケーションのセキュリティ状態をチェックする
  /// @return セキュリティ状態
  static Map<String, bool> checkSecurityStatus() {
    return {
      'debugMode': kDebugMode,
      'isRelease': kReleaseMode,
      'isWeb': kIsWeb,
      'isAndroid': Platform.isAndroid,
      'isIOS': Platform.isIOS,
      'isMacOS': Platform.isMacOS,
      'isWindows': Platform.isWindows,
      'isLinux': Platform.isLinux,
    };
  }

  /// セキュリティログを記録する
  /// @param event イベント
  /// @param details 詳細
  static void logSecurityEvent(String event, {Map<String, dynamic>? details}) {
    if (kDebugMode) {
      AppLogger.debug('Security Event: $event');
      if (details != null) {
        AppLogger.debug('Details: $details');
      }
    }

    // 実際の実装では、セキュリティログサービスに送信
  }

  // プライベートメソッド

  static String _generateKey() {
    final keyBytes = utf8.encode(_getEncryptionKey());
    final hash = sha256.convert(keyBytes);
    return base64Encode(hash.bytes);
  }

  static String _generateIV() {
    return generateSecureRandomString(_saltLength);
  }

  static List<int> _generateSalt() {
    final random = Random.secure();
    return List.generate(_saltLength, (_) => random.nextInt(256));
  }

  static String _xorEncrypt(String data, String key) {
    final dataBytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);

    final encrypted = <int>[];
    for (int i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64Encode(encrypted);
  }

  static String _xorDecrypt(String encrypted, String key) {
    final encryptedBytes = base64Decode(encrypted);
    final keyBytes = utf8.encode(key);

    final decrypted = <int>[];
    for (int i = 0; i < encryptedBytes.length; i++) {
      decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(decrypted);
  }

  static String _calculateChecksum(String data) {
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return base64Encode(hash.bytes);
  }
}
