import 'package:flutter_test/flutter_test.dart';
import 'package:tea_garden_ai/core/constants/app_constants.dart';
import 'package:tea_garden_ai/features/camera/domain/entities/camera_capture_result.dart';

/*
 * CameraCaptureResultの互換パースを検証する
 * - 型付き戻り値とMap戻り値の両方を受け取れることを保証する
 */
void main() {
  test('fromDynamic: CameraCaptureResultをそのまま返す', () {
    const original = CameraCaptureResult(imagePath: '/tmp/a.png');
    final parsed = CameraCaptureResult.fromDynamic(original);
    expect(parsed, same(original));
  });

  test('fromDynamic: MapからimagePathを抽出できる', () {
    final parsed = CameraCaptureResult.fromDynamic({
      NavigationResultKeys.cameraImagePath: '/tmp/a.png',
    });
    expect(parsed?.imagePath, '/tmp/a.png');
    expect(parsed?.errorMessage, isNull);
  });

  test('fromDynamic: Mapからerrorを抽出できる', () {
    final parsed = CameraCaptureResult.fromDynamic({
      NavigationResultKeys.cameraErrorMessage: 'oops',
    });
    expect(parsed?.imagePath, isNull);
    expect(parsed?.errorMessage, 'oops');
  });

  test('fromDynamic: 型不一致の値はnullとして扱う', () {
    final parsed = CameraCaptureResult.fromDynamic({
      NavigationResultKeys.cameraImagePath: 123,
      NavigationResultKeys.cameraErrorMessage: true,
    });
    expect(parsed?.imagePath, isNull);
    expect(parsed?.errorMessage, isNull);
  });

  test('fromDynamic: nullはnullを返す', () {
    final parsed = CameraCaptureResult.fromDynamic(null);
    expect(parsed, isNull);
  });
}
