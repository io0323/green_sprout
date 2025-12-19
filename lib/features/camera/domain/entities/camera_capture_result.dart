import '../../../../core/constants/app_constants.dart';

/*
 * カメラ撮影結果の戻り値
 * - 画面遷移の戻り値を型で表現し、Mapのキー直書きを避ける
 * - 既存のMap戻り値との互換のため toMap/fromDynamic も提供する
 */
class CameraCaptureResult {
  /* 撮影した画像のパス */
  final String? imagePath;

  /* エラーメッセージ（カメラ画面側でメッセージを返したい場合） */
  final String? errorMessage;

  /*
   * コンストラクタ
   * - imagePathかerrorMessageのどちらか（または両方null=キャンセル）を想定
   */
  const CameraCaptureResult({
    this.imagePath,
    this.errorMessage,
  });

  /* キャンセル用（戻り値が不要な場合） */
  static const CameraCaptureResult cancelled = CameraCaptureResult();

  /*
   * 互換用: 動的な戻り値からCameraCaptureResultへ変換する
   * - すでにCameraCaptureResultならそのまま返す
   * - Mapなら既知キーから抽出して返す
   * - それ以外はnull
   */
  static CameraCaptureResult? fromDynamic(Object? result) {
    if (result == null) return null;
    if (result is CameraCaptureResult) return result;
    if (result is Map) {
      final imagePath = result[NavigationResultKeys.cameraImagePath];
      final error = result[NavigationResultKeys.cameraErrorMessage];
      return CameraCaptureResult(
        imagePath: imagePath is String ? imagePath : null,
        errorMessage: error is String ? error : null,
      );
    }
    return null;
  }

  /*
   * 互換用: Mapへ変換する
   * - null項目は含めず、呼び出し側の扱いを単純化する
   */
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (imagePath != null) {
      map[NavigationResultKeys.cameraImagePath] = imagePath;
    }
    if (errorMessage != null) {
      map[NavigationResultKeys.cameraErrorMessage] = errorMessage;
    }
    return map;
  }
}
