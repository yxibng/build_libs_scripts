#!/bin/bash
# 编译 exiv2 静态库，C++17，支持 XMP，macOS arm64
set -e

BUILD_DIR="build-macos-arm64"
INSTALL_DIR="install-macos-arm64"

# 编译前清理 build 和 install 目录
rm -rf "$BUILD_DIR" "$INSTALL_DIR"

# 创建构建目录
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 配置 CMake
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_CXX_STANDARD=17 \
  -DEXIV2_ENABLE_XMP=ON \
  -DEXIV2_ENABLE_BROTLI=OFF \
  -DEXIV2_ENABLE_PNG=OFF \
  -DEXIV2_ENABLE_LENSDATA=OFF \
  -DEXIV2_ENABLE_INIH=OFF \
  -DEXIV2_BUILD_SAMPLES=OFF \
  -DEXIV2_BUILD_EXIV2_COMMAND=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_INSTALL_PREFIX="../$INSTALL_DIR"

# 编译并安装
cmake --build . --config Release --target install
