import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/core/utils/platform_utils.dart';

/**
 * PlatformUtilsのテスト
 */
void main() {
  group('PlatformUtils', () {
    test('isWebはfalseを返す（テスト環境ではWebではない）', () {
      expect(PlatformUtils.isWeb, false);
    });

    test('isMobileはtrueを返す（テスト環境ではモバイル）', () {
      expect(PlatformUtils.isMobile, true);
    });

    test('isWearOSはfalseを返す（テスト環境ではWear OSではない）', () {
      expect(PlatformUtils.isWearOS, false);
    });

    test('isWatchOSはfalseを返す（テスト環境ではwatchOSではない）', () {
      expect(PlatformUtils.isWatchOS, false);
    });

    test('isWearableはfalseを返す（テスト環境ではウェアラブルではない）', () {
      expect(PlatformUtils.isWearable, false);
    });

    test('isStandardMobileはtrueを返す（テスト環境では標準モバイル）', () {
      expect(PlatformUtils.isStandardMobile, true);
    });
  });
}
