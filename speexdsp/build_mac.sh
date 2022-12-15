#!/bin/bash
	
    SYS_ROOT=$(xcrun --sdk macosx --show-sdk-path)


    #   --disable-binaries   Do not build the encoder and decoder programs, only the library

    #     --with-sysroot[=DIR]    Search for dependent libraries within DIR (or the
    #                       compiler's sysroot if not specified).


#       CFLAGS      C compiler flags
#   LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
#               nonstandard directory <lib dir>

make clean 

export CFLAGS="-mmacosx-version-min=10.13"
export LDFLAGS=$CFLAGS


./configure   --enable-shared=no \
 --disable-examples \
 --host=arm64-apple-darwin \
--with-sysroot=$SYS_ROOT \
--prefix=`pwd`/macos_output

make -j 10
make install 