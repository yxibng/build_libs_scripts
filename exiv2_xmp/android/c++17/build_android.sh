#!/bin/bash
# build_android.sh - Build Exiv2 for Android (arm64-v8a, armeabi-v7a, minSdk 21, with XMP)
# Usage: ANDROID_NDK=/path/to/ndk ./build_android.sh [ABI]
#   ABI: arm64-v8a (default) or armeabi-v7a

set -e

if [ -z "$ANDROID_NDK" ]; then
  echo "Please set ANDROID_NDK to your Android NDK path."
  exit 1
fi

# 设置 ABI 参数，默认为 arm64-v8a
ABI=${1:-arm64-v8a}

# 验证 ABI 参数
if [ "$ABI" != "arm64-v8a" ] && [ "$ABI" != "armeabi-v7a" ]; then
  echo "Error: Invalid ABI '$ABI'. Supported ABIs: arm64-v8a, armeabi-v7a"
  exit 1
fi

BUILD_DIR=build-android-$ABI
OUTPUT_DIR=output_android/$ABI
MIN_SDK=21

echo "Building Exiv2 for Android with ABI: $ABI"

# 清理旧的构建目录和输出目录
echo "Cleaning previous build..."
rm -rf $BUILD_DIR
rm -rf $OUTPUT_DIR
echo "Clean complete."

cmake -B $BUILD_DIR \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=$ABI \
  -DANDROID_PLATFORM=android-$MIN_SDK \
  -DEXIV2_ENABLE_XMP=ON \
  -DEXIV2_ENABLE_PNG=OFF \
  -DEXIV2_ENABLE_LENSDATA=OFF \
  -DEXIV2_ENABLE_INIH=OFF \
  -DEXIV2_BUILD_SAMPLES=OFF \
  -DEXIV2_BUILD_EXIV2_COMMAND=OFF \
  -DEXIV2_ENABLE_FILESYSTEM_ACCESS=ON \
  -DEXIV2_ENABLE_BROTLI=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DEXPAT_LIBRARY=$(pwd)/contrib/android-libs/lib/$ABI/libexpat.a \
  -DEXPAT_INCLUDE_DIR=$(pwd)/contrib/android-libs/include \
  -DEXPAT_LIBRARIES=$(pwd)/contrib/android-libs/lib/$ABI/libexpat.a

cmake --build $BUILD_DIR

# 创建输出目录
mkdir -p "$OUTPUT_DIR/lib"
mkdir -p "$OUTPUT_DIR/include/exiv2"

# 复制静态库
cp "$BUILD_DIR"/lib/*.a "$OUTPUT_DIR/lib/" 2>/dev/null || true
cp "contrib/android-libs/lib/$ABI/libexpat.a" "$OUTPUT_DIR/lib/"

# 复制头文件
cp -r include/* "$OUTPUT_DIR/include/"

# 复制构建生成的配置头文件
cp "$BUILD_DIR/exv_conf.h" "$OUTPUT_DIR/include/exiv2/"
cp "$BUILD_DIR/exiv2lib_export.h" "$OUTPUT_DIR/include/exiv2/"

echo "Build complete. Output in $OUTPUT_DIR"
echo "  - Static libraries: $OUTPUT_DIR/lib/"
echo "  - Header files: $OUTPUT_DIR/include/"
echo ""
echo "To use in your Android project:"
echo "  - Add $OUTPUT_DIR/lib to your library search path"
echo "  - Add $OUTPUT_DIR/include to your include search path"
echo "  - Link with: -lexiv2 -lexiv2-xmp -lexpat"
echo ""
echo "Examples:"
echo "  Build for arm64-v8a:  ANDROID_NDK=/path/to/ndk ./build_android.sh arm64-v8a"
echo "  Build for armeabi-v7a: ANDROID_NDK=/path/to/ndk ./build_android.sh armeabi-v7a"
