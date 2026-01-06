#!/bin/bash
# 编译 exiv2 静态库，C++14，支持 XMP，macOS arm64
set -e

BUILD_DIR="build-macos-arm64"
INSTALL_DIR="install-macos-arm64"

# 删除旧的构建和安装目录
echo "清理旧的构建和安装目录..."
rm -rf "$BUILD_DIR"
rm -rf "$INSTALL_DIR"

# 创建构建目录
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 配置 CMake
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_CXX_STANDARD=14 \
  -DEXIV2_ENABLE_XMP=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DEXIV2_ENABLE_PNG=OFF \
  -DEXIV2_ENABLE_LENSDATA=OFF \
  -DEXIV2_BUILD_SAMPLES=OFF \
  -DEXIV2_BUILD_EXIV2_COMMAND=OFF \
  -DEXIV2_ENABLE_PRINTUCS2=OFF \
  -DCMAKE_INSTALL_PREFIX="../$INSTALL_DIR"

# 编译并安装
cmake --build . --config Release --target install

echo "静态库编译完成，安装路径: $INSTALL_DIR"
