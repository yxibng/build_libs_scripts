#!/bin/bash

# 使用说明
#
# 作用:
#   交叉编译 FFmpeg 到 Android，输出静态库（.a）和头文件（include/）。
#   支持 ABI: arm64-v8a、armeabi-v7a。
#   可选链接本机已编译好的 x264 静态库（libx264.a）。
#
# 依赖:
#   1) Android NDK (脚本默认使用 NDK r21e):
#        NDK_PATH="/Users/yaoxiaobing/Library/Android/sdk/ndk/21.4.7075529"
#      如 NDK 不在该路径，请修改下方 NDK_PATH。
#
#   2) x264 Android 静态库（可选，但建议）:
#      目录结构应为（每个 ABI 一份）:
#        /Users/yaoxiaobing/Github/x264/android-build/arm64-v8a/include
#        /Users/yaoxiaobing/Github/x264/android-build/arm64-v8a/lib/libx264.a
#        /Users/yaoxiaobing/Github/x264/android-build/armeabi-v7a/include
#        /Users/yaoxiaobing/Github/x264/android-build/armeabi-v7a/lib/libx264.a
#      若某个 ABI 缺少 libx264.a，本脚本会对该 ABI 自动跳过 --enable-libx264。
#
# 运行:
#   先赋予执行权限:
#     chmod +x ./build_ffmpeg_android.sh
#
#   构建单个 ABI:
#     ./build_ffmpeg_android.sh 1        # arm64-v8a
#     ./build_ffmpeg_android.sh 2        # armeabi-v7a
#
#   构建全部 ABI:
#     ./build_ffmpeg_android.sh 3
#
#   不带参数则进入交互选择:
#     ./build_ffmpeg_android.sh
#
# 输出:
#   默认输出目录为当前 FFmpeg 仓库下的 android-build/:
#     android-build/arm64-v8a/{include,lib}
#     android-build/armeabi-v7a/{include,lib}
#
# 备注:
#   - 本脚本不依赖 pkg-config 来检测 x264，直接通过 -I/-L 和 -lx264 链接。
#   - 默认最小 API_LEVEL=21；如需调整请修改脚本中的 API_LEVEL。

# FFmpeg Android 构建脚本
# 支持 arm64-v8a 和 armeabi-v7a 架构
# 构建静态库并链接 x264

set -e

# ==================== 配置部分 ====================

# NDK 路径 - 用户指定
NDK_PATH="/Users/yaoxiaobing/Library/Android/sdk/ndk/21.4.7075529"

# x264 库路径
X264_PREFIX="/Users/yaoxiaobing/Github/x264/android-build"

# 输出路径
OUTPUT_PREFIX="$(pwd)/android-build"

# 最小 Android API 级别
API_LEVEL=21

# ==================== 函数定义 ====================

function check_ndk() {
    if [ ! -d "$NDK_PATH" ]; then
        echo "错误: NDK 路径不存在: $NDK_PATH"
        echo "请设置正确的 ANDROID_NDK_HOME 环境变量或修改脚本中的 NDK_PATH"
        exit 1
    fi
    echo "使用 NDK: $NDK_PATH"
}

function check_x264() {
    if [ ! -d "$X264_PREFIX" ]; then
        echo "错误: x264 库路径不存在: $X264_PREFIX"
        exit 1
    fi
    echo "使用 x264: $X264_PREFIX"
}

function build_android() {
    local ABI=$1
    local CPU=$2
    local PLATFORM=$3
    local TOOLCHAIN_PREFIX=$4

    local FFMPEG_ARCH=""
    case "$ABI" in
        arm64-v8a)   FFMPEG_ARCH="aarch64" ;;
        armeabi-v7a) FFMPEG_ARCH="arm" ;;
        *)
            echo "错误: 未知 ABI: $ABI"
            exit 1
            ;;
    esac
    
    echo "===================="
    echo "开始构建 $ABI 架构"
    echo "===================="
    
    # 设置目标架构的 x264 路径
    local X264_ARCH_PREFIX="$X264_PREFIX/$ABI"

    local X264_LIB_PATH=""
    local EXTRA_LDFLAGS=""
    local EXTRA_LIBS=""

    if [ ! -d "$X264_ARCH_PREFIX" ]; then
        echo "警告: x264 $ABI 库不存在: $X264_ARCH_PREFIX"
        echo "将不链接 x264，如需 x264 支持请先构建对应架构的 x264"
        ENABLE_X264=""
    else
        ENABLE_X264="--enable-libx264"
        echo "找到 x264 $ABI 库: $X264_ARCH_PREFIX"
        if [ -f "$X264_ARCH_PREFIX/lib/libx264.a" ]; then
            X264_LIB_PATH="$X264_ARCH_PREFIX/lib/libx264.a"
            echo "使用静态 x264 库: $X264_LIB_PATH"
            # 让 configure/link 阶段可以通过 -L... -lx264 找到静态库
            EXTRA_LIBS="-lx264 -lm -ldl"
        else
            echo "警告: 未找到 $X264_ARCH_PREFIX/lib/libx264.a，将不启用 libx264"
            ENABLE_X264=""
        fi
    fi
    
    # 输出目录（每次构建前清理该 ABI 的上次产物，避免残留文件混入）
    local PREFIX="$OUTPUT_PREFIX/$ABI"
    rm -rf "$PREFIX"
    mkdir -p "$PREFIX"
    
    # 清理之前的构建/配置（多架构连续构建时避免复用上一次的检测结果）
    make distclean 2>/dev/null || make clean 2>/dev/null || true
    rm -f ffbuild/config.log ffbuild/config.mak config.h config.mak
    
    # Toolchain 路径
    local TOOLCHAIN="$NDK_PATH/toolchains/llvm/prebuilt/darwin-x86_64"
    local SYSROOT="$TOOLCHAIN/sysroot"
    
    # 编译器设置
    local CC="$TOOLCHAIN/bin/${TOOLCHAIN_PREFIX}${API_LEVEL}-clang"
    local CXX="$TOOLCHAIN/bin/${TOOLCHAIN_PREFIX}${API_LEVEL}-clang++"
    local AR="$TOOLCHAIN/bin/llvm-ar"
    local AS="$CC"
    local LD="$TOOLCHAIN/bin/ld"
    local NM="$TOOLCHAIN/bin/llvm-nm"
    local STRIP="$TOOLCHAIN/bin/llvm-strip"
    local RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
    
    # 编译标志
    local CFLAGS="-O3 -fPIC -DANDROID -D__ANDROID_API__=$API_LEVEL"
    local LDFLAGS="-L$SYSROOT/usr/lib/$TOOLCHAIN_PREFIX/$API_LEVEL"
    
    # 如果有 x264，添加相关路径
    if [ -n "$ENABLE_X264" ]; then
        CFLAGS="$CFLAGS -I$X264_ARCH_PREFIX/include"
        LDFLAGS="$LDFLAGS -L$X264_ARCH_PREFIX/lib"
    fi
    
    # 配置参数
    ./configure \
        --prefix=$PREFIX \
        --enable-static \
        --disable-shared \
        --disable-doc \
        --disable-htmlpages \
        --disable-manpages \
        --disable-podpages \
        --disable-txtpages \
        --disable-programs \
        --disable-ffmpeg \
        --disable-ffplay \
        --disable-ffprobe \
        --enable-cross-compile \
        --target-os=android \
        --arch=$FFMPEG_ARCH \
        --cpu=$CPU \
        --cc="$CC" \
        --cxx="$CXX" \
        --ar="$AR" \
        --as="$AS" \
        --nm="$NM" \
        --ranlib="$RANLIB" \
        --strip="$STRIP" \
        --sysroot="$SYSROOT" \
        --extra-cflags="$CFLAGS" \
        --extra-ldflags="$LDFLAGS" \
        --enable-gpl \
        --enable-version3 \
        $ENABLE_X264 \
        --disable-asm \
        --disable-inline-asm \
        --enable-jni \
        --enable-mediacodec \
        --enable-decoder=h264_mediacodec \
        --enable-decoder=hevc_mediacodec \
        --enable-decoder=mpeg4_mediacodec \
        --enable-decoder=vp8_mediacodec \
        --enable-decoder=vp9_mediacodec \
        --extra-libs="$EXTRA_LIBS"
    
    # 编译
    make clean
    make -j$(sysctl -n hw.ncpu)
    make install
    
    echo "===================="
    echo "$ABI 构建完成"
    echo "输出路径: $PREFIX"
    echo "===================="
}

# ==================== 主程序 ====================

echo "FFmpeg Android 构建脚本"
echo "======================="

# 检查环境
check_ndk
check_x264

# 选择要构建的架构
if [ -z "$1" ]; then
    echo "选择要构建的架构:"
    echo "1) arm64-v8a"
    echo "2) armeabi-v7a"
    echo "3) 全部"
    read -p "请输入选项 (1-3): " choice
else
    choice=$1
fi

    case $choice in
        1|arm64|arm64-v8a)
            echo "仅构建 arm64-v8a"
            build_android "arm64-v8a" "armv8-a" "android-$API_LEVEL" "aarch64-linux-android"
            ;;
        2|armv7|armeabi-v7a)
            echo "仅构建 armeabi-v7a"
            build_android "armeabi-v7a" "armv7-a" "android-$API_LEVEL" "armv7a-linux-androideabi"
            ;;
        3|all)
            echo "构建所有架构"
            build_android "arm64-v8a" "armv8-a" "android-$API_LEVEL" "aarch64-linux-android"
            build_android "armeabi-v7a" "armv7-a" "android-$API_LEVEL" "armv7a-linux-androideabi"
            ;;
        *)
            echo "无效选项"
            exit 1
            ;;
    esac

echo ""
echo "======================="
echo "所有构建完成！"
echo "输出目录: $OUTPUT_PREFIX"
echo "======================="
echo ""
echo "静态库位置:"
echo "  arm64-v8a: $OUTPUT_PREFIX/arm64-v8a/lib/"
echo "  armeabi-v7a: $OUTPUT_PREFIX/armeabi-v7a/lib/"
echo ""
