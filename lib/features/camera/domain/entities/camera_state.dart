/**
 * カメラ状態のドメインエンティティ
 * カメラの状態を表現する
 */
class CameraState {
  final bool isInitialized;
  final bool isCapturing;
  final String? errorMessage;
  final String? capturedImagePath;

  const CameraState({
    this.isInitialized = false,
    this.isCapturing = false,
    this.errorMessage,
    this.capturedImagePath,
  });

  /**
   * 新しい状態でインスタンスを更新
   */
  CameraState copyWith({
    bool? isInitialized,
    bool? isCapturing,
    String? errorMessage,
    String? capturedImagePath,
  }) {
    return CameraState(
      isInitialized: isInitialized ?? this.isInitialized,
      isCapturing: isCapturing ?? this.isCapturing,
      errorMessage: errorMessage ?? this.errorMessage,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
    );
  }

  /**
   * エンティティの等価性を比較
   */
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CameraState &&
        other.isInitialized == isInitialized &&
        other.isCapturing == isCapturing &&
        other.errorMessage == errorMessage &&
        other.capturedImagePath == capturedImagePath;
  }

  /**
   * ハッシュコードを生成
   */
  @override
  int get hashCode {
    return Object.hash(
      isInitialized,
      isCapturing,
      errorMessage,
      capturedImagePath,
    );
  }

  /**
   * 文字列表現
   */
  @override
  String toString() {
    return 'CameraState(isInitialized: $isInitialized, isCapturing: $isCapturing, errorMessage: $errorMessage, capturedImagePath: $capturedImagePath)';
  }

  /**
   * エラーが発生しているかどうかを判定
   */
  bool get hasError {
    return errorMessage != null && errorMessage!.isNotEmpty;
  }

  /**
   * 画像が撮影されているかどうかを判定
   */
  bool get hasCapturedImage {
    return capturedImagePath != null && capturedImagePath!.isNotEmpty;
  }
}
