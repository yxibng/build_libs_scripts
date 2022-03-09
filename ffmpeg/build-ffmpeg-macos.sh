SCRIPT_DIR="$(
    cd "$(dirname "$0")"
    pwd
)"


# 是否开启调试
DEBUG=false

# 静态库输出目录
OUTPUT=$SCRIPT_DIR/ffmpeg-macos

#clean last build
if [ -e $OUTPUT ]; then 
	rm -rf $OUTPUT
fi

#make output dir
mkdir -p $OUTPUT

# absolute path to x264 library
X264=./x264-macos/lipo

SYS_ROOT=`xcrun --sdk macosx --show-sdk-path`


if [ $DEBUG = true ]; then
# 添加调试符号
CONFIGURE_FLAGS="--enable-debug=3 --disable-optimizations --disable-stripping"
else
# 不支持调试
CONFIGURE_FLAGS="--disable-debug"
fi

CONFIGURE_FLAGS="${CONFIGURE_FLAGS} \
				--enable-static \
				--disable-programs \
				--disable-symver \
				--disable-htmlpages \
				--disable-manpages \
				--disable-podpages \
				--disable-cuda \
				--disable-cuvid \
				--disable-nvenc \
				--disable-lzma \
                --disable-doc --enable-pic --disable-asm --disable-inline-asm"

CFLAGS="-fvisibility=hidden -fembed-bitcode -mmacosx-version-min=10.12"

#test if link to x264
if [ -f $X264 ]; then
	echo "x264 exist, set link config, path = $X264"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-gpl --enable-libx264"
	CFLAGS="$CFLAGS -I$X264/include"
	LDFLAGS="$LDFLAGS -L$X264/lib"
fi


# clean build 
if [ -e $OUTPUT ]; then 
	rm -rf $OUTPUT
fi

# build libs
for arch in arm64 x86_64
do 

	make clean

	ARCH_DIR=$OUTPUT/$arch
	mkdir -p $ARCH_DIR

	if [ $arch = arm64 ]; then
		CPU=
	else
		CPU="--cpu=$arch"
	fi

	./configure $CONFIGURE_FLAGS $SYSROOT --sysroot=$SYS_ROOT --prefix=$ARCH_DIR --enable-cross-compile \
	--target-os=darwin --arch=${arch} --cc=/usr/bin/clang $CPU \
	--extra-cflags="-arch $arch -I/usr/local/include $CFLAGS" \
	--extra-ldflags="-arch $arch -L/usr/local/lib -isysroot $SYS_ROOT $LDFLAGS" 

	make -j 16
	make install
done

if [ $? != 0 ]; then 
	echo "build static lib failed"
	exit 1
fi

# lipo
echo "make universal ffmpeg libs for macos with lipo"

X64_DIR="$OUTPUT/x86_64"
ARM64_DIR="$OUTPUT/arm64"

LIPO_DIR="$OUTPUT/lipo"

cp -R $X64_DIR $LIPO_DIR

LIBS=`ls $LIPO_DIR/lib | grep "\.a"`

for name in $LIBS 
do 
	lipo $X64_DIR/lib/$name $ARM64_DIR/lib/$name -create -output $LIPO_DIR/lib/$name
done

echo "successfully make universal ffmpeg in $LIPO_DIR"

open $LIPO_DIR




