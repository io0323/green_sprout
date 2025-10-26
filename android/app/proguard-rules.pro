# Keep TensorFlow Lite runtime and GPU delegate
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.**

# Keep TensorFlow Lite GPU delegate specifically
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**

# Keep native methods used by TensorFlow Lite
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep classes that might be accessed via reflection
-keep class * extends java.lang.Exception
-keep class * extends java.lang.RuntimeException

# Additional TensorFlow Lite specific rules
-keep class org.tensorflow.lite.Interpreter { *; }
-keep class org.tensorflow.lite.Interpreter$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
