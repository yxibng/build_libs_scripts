#/bin/zsh

SCRIPT_DIR="$(
    cd "$(dirname "$0")"
    pwd
)"

cd $SCRIPT_DIR

rm -rf output

# build arm64 ios
rm -rf build
mkdir build
cd build
cmake $SCRIPT_DIR -G Xcode -DCMAKE_TOOLCHAIN_FILE=$SCRIPT_DIR/ios.toolchain.cmake -DPLATFORM=OS64 -DDEPLOYMENT_TARGET=12.0 -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO -DINTEGER_SAMPLES=ON
cmake --build . --config Release
cmake --install . --config Release --prefix $SCRIPT_DIR/output/OS64

exit 0


cd $SCRIPT_DIR

# build arm64 simulator
rm -rf build
mkdir build
cd build
cmake $SCRIPT_DIR -G Xcode -DCMAKE_TOOLCHAIN_FILE=$SCRIPT_DIR/ios.toolchain.cmake -DPLATFORM=SIMULATORARM64
cmake --build . --config Release
cmake --install . --config Release --prefix $SCRIPT_DIR/output/SIMULATORARM64

# build x86_64 ios simulator
rm -rf build
mkdir build
cd build
cmake $SCRIPT_DIR -G Xcode -DCMAKE_TOOLCHAIN_FILE=$SCRIPT_DIR/ios.toolchain.cmake -DPLATFORM=SIMULATOR64
cmake --build . --config Release
cmake --install . --config Release --prefix $SCRIPT_DIR/output/SIMULATOR64

# lipo simulators
lipo -create $SCRIPT_DIR/output/SIMULATOR64/lib/libopus.a $SCRIPT_DIR/output/SIMULATORARM64/lib/libopus.a -output $SCRIPT_DIR/output/libopus.a

# generate xcframework
xcodebuild -create-xcframework \
    -library $SCRIPT_DIR/output/OS64/lib/libopus.a -headers $SCRIPT_DIR/output/OS64/include \
    -library $SCRIPT_DIR/output/libopus.a -headers $SCRIPT_DIR/output/SIMULATORARM64/include \
    -output $SCRIPT_DIR/output/opus.xcframework

open $SCRIPT_DIR/output/
