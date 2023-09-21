#/bin/zsh

SCRIPT_DIR="$(
    cd "$(dirname "$0")"
    pwd
)"

cd $SCRIPT_DIR

rm -rf output

cd $SCRIPT_DIR
rm -rf build
mkdir build
cd build
python $SCRIPT_DIR/platforms/apple/build_xcframework.py -o $SCRIPT_DIR/output --iphoneos_archs arm64 --iphonesimulator_archs "arm64,x86_64" --iphoneos_deployment_targe 11.0 --build_only_specified_archs

open $SCRIPT_DIR/output
