#!/bin/bash
# build_expat_android.sh - Build static EXPAT library for Android (arm64-v8a, armeabi-v7a)
# Usage: ANDROID_NDK=/path/to/ndk ./build_expat_android.sh [ABI]
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

EXPAT_VERSION="2.6.2"

# Download EXPAT if not present
EXPAT_SRC_DIR="expat-$EXPAT_VERSION"
EXPAT_TAR="R_${EXPAT_VERSION//./_}.tar.gz"
if [ ! -d "$EXPAT_SRC_DIR" ]; then
  if [ ! -f "$EXPAT_TAR" ]; then
    curl -LO "https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VERSION//./_}/expat-$EXPAT_VERSION.tar.gz"
    mv "expat-$EXPAT_VERSION.tar.gz" "$EXPAT_TAR"
  fi
  tar xf "$EXPAT_TAR"
fi

cd "$EXPAT_SRC_DIR"

BUILD_DIR="build-android-$ABI"
mkdir -p $BUILD_DIR
cd $BUILD_DIR

cmake .. \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=$ABI \
  -DANDROID_PLATFORM=android-21 \
  -DBUILD_SHARED_LIBS=OFF \
  -DEXPAT_BUILD_TOOLS=OFF \
  -DEXPAT_BUILD_EXAMPLES=OFF \
  -DEXPAT_BUILD_TESTS=OFF

cmake --build .



# Copy artifacts to contrib/android-libs
cd ../..
mkdir -p contrib/android-libs/lib/$ABI
mkdir -p contrib/android-libs/include

echo "Copying library..."
cp $EXPAT_SRC_DIR/$BUILD_DIR/libexpat.a contrib/android-libs/lib/$ABI/

echo "Copying headers..."
cp $EXPAT_SRC_DIR/lib/expat.h contrib/android-libs/include/
cp $EXPAT_SRC_DIR/lib/expat_external.h contrib/android-libs/include/
cp $EXPAT_SRC_DIR/$BUILD_DIR/expat_config.h contrib/android-libs/include/
echo "EXPAT build complete for ABI: $ABI"
echo "Library: contrib/android-libs/lib/$ABI/libexpat.a"
echo "Headers: contrib/android-libs/include/"
