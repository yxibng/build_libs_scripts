#!/bin/bash
	
    SYS_ROOT=$(xcrun --sdk iphoneos --show-sdk-path)


    #   --disable-binaries   Do not build the encoder and decoder programs, only the library

    #     --with-sysroot[=DIR]    Search for dependent libraries within DIR (or the
    #                       compiler's sysroot if not specified).


#       CFLAGS      C compiler flags
#   LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
#               nonstandard directory <lib dir>



make clean 

export CFLAGS="-arch arm64 -mios-version-min=11.0"
export LDFLAGS=$CFLAGS

./configure  --enable-shared=no \
 --disable-examples \
--with-sysroot=$SYS_ROOT \
--host=aarch64-apple-darwin \
--prefix=`pwd`/ios_output

make -j 10
make install 
