#!/usr/bin/env bash
set -euo pipefail

# One-shot clean rebuild for Android using a fixed NDK path.
# Edit NDK_PATH below if your NDK location changes.

NDK_PATH="/Users/yaoxiaobing/Library/Android/sdk/ndk/21.4.7075529"

rm -rf android-build build-android
export ANDROID_NDK_HOME="$NDK_PATH"

./build_android.sh
