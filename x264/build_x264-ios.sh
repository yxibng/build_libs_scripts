#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)";

ARCHS_IPHONEOS="arm64 armv7"
ARCHS_SIMULATOR="arm64 x86_64"

PRODUCTS_DIR=$SCRIPT_DIR/products
CONFIGURE_FLAGS="--enable-static --enable-pic --disable-cli"

build_for_iphone() {
	XCRUN_SDK=iphoneos
	SYS_ROOT=`xcrun -sdk $XCRUN_SDK --show-sdk-path`
	for ARCH in $ARCHS_IPHONEOS
	do 
		if [ $ARCH = arm64 ]; then 
			XARCH="-arch aarch64"
			HOST="--host=aarch64-apple-darwin"
			CONFIG=$CONFIGURE_FLAGS
			CC="xcrun -sdk $XCRUN_SDK clang"
			export AS="./tools/gas-preprocessor.pl $XARCH -- $CC"
		else
			unset CC
			unset AS
			XARCH="-arch arm"
			HOST="--host=arm-apple-darwin"
			CONFIG="$CONFIGURE_FLAGS --disable-asm"
		fi
		PREFIX=$PRODUCTS_DIR/iphoneos/$ARCH
		[ -e $PREFIX ] && rm -rf $PREFIX
		mkdir -p $PREFIX
		CFLAGS="-arch $ARCH -fembed-bitcode -mios-version-min=9.0"
		LDFLAGS="$CFLAGS"
		ASFLAGS="$CFLAGS"		
		./configure $CONFIG \
		$HOST \
		--sysroot=$SYS_ROOT \
		--extra-cflags="$CFLAGS" \
		--extra-asflags="$ASFLAGS" \
		--extra-ldflags="$LDFLAGS" \
		--prefix=$PREFIX
		make -j `sysctl -n hw.logicalcpu` install
	done
}


build_for_simulator() {
	XCRUN_SDK=iphonesimulator
	SYS_ROOT=`xcrun -sdk $XCRUN_SDK --show-sdk-path`
	for ARCH in $ARCHS_SIMULATOR
	do 
		if [ $ARCH = arm64 ]; then 
			XARCH="-arch aarch64"
			HOST="--host=aarch64-apple-darwin"
			CONFIG=$CONFIGURE_FLAGS
			CC="xcrun -sdk $XCRUN_SDK clang"
			export AS="./tools/gas-preprocessor.pl $XARCH -- $CC"
		else
			unset CC
			unset AS
			XARCH="-arch arm"
			HOST="--host=x86_64-apple-darwin"
			CONFIG="$CONFIGURE_FLAGS --disable-asm"
		fi
		PREFIX=$PRODUCTS_DIR/iphonesimulator/$ARCH
		[ -e $PREFIX ] && rm -rf $PREFIX
		mkdir -p $PREFIX
		CFLAGS="-arch $ARCH -fembed-bitcode -mios-simulator-version-min=9.0"
		LDFLAGS="$CFLAGS"
		ASFLAGS="$CFLAGS"		
		./configure $CONFIG \
		$HOST \
		--sysroot=$SYS_ROOT \
		--extra-cflags="$CFLAGS" \
		--extra-asflags="$ASFLAGS" \
		--extra-ldflags="$LDFLAGS" \
		--prefix=$PREFIX
		make -j `sysctl -n hw.logicalcpu` install
	done

}

build_for_iphone
build_for_simulator
