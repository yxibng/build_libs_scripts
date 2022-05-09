
#/bin/bash


# 关于host指定，参考 https://opensource.apple.com/source/gdb/gdb-1518/Makefile.auto.html

# i386-apple-darwin 
# x86_64-apple-darwin
# arm-apple-darwin

# 关于deployment target 的指定, 参考 https://github.com/llvm-mirror/clang/blob/master/include/clang/Driver/Options.td

# -mmacosx-version-min=
# -mios-simulator-version-min=
# -mios-version-min=


SCRIPT_DIR="$(
    cd "$(dirname "$0")"
    pwd
)"

for arch in arm64 x86_64 
do 
    CONFIGURE_FLAGS="--enable-static --enable-pic --disable-cli"
    Output="$SCRIPT_DIR/x264-macos/$arch"
    mkdir -p $Output

    SYS_ROOT=`xcrun --show-sdk-path`
    CFLAGS="-arch $arch -fvisibility=hidden  -fembed-bitcode -mmacosx-version-min=10.12"

    make clean

    ./configure $CONFIGURE_FLAGS  --prefix=$Output --extra-cflags="$CFLAGS" --host=$arch-apple-darwin  -isysroot=$SYS_ROOT
  
    make -j `nproc`
    make install
done


if [ $? != 0 ]; then 
    echo "build libx264 failed"
    exit 1
fi 

echo "make universal libx264 with lipo"

X64_DIR="$SCRIPT_DIR/x264-macos/x86_64"
ARM64_DIR="$SCRIPT_DIR/x264-macos/arm64"

LIPO_DIR="$SCRIPT_DIR/x264-macos/lipo"

cp -R $X64_DIR $LIPO_DIR

lipo $X64_DIR/lib/libx264.a $ARM64_DIR/lib/libx264.a -create -output $LIPO_DIR/lib/libx264.a

echo "successfully make universal libx264 in $LIPO_DIR"

open $LIPO_DIR









