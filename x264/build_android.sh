#!/usr/bin/env bash
set -euo pipefail

# Minimal x264 Android build script
# Supports only: arm64 (arm64-v8a) and armv7 (armeabi-v7a)
# Usage:
#   ./build_android.sh
#   ANDROID_NDK_HOME=/path/to/ndk ./build_android.sh
#   ./build_android.sh /path/to/android-ndk
#   ./build_android.sh --ndk /path/to/android-ndk
#   ./build_android.sh --no-clean

DEFAULT_NDK_PATH="/Users/yaoxiaobing/Library/Android/sdk/ndk/21.4.7075529"
DEFAULT_ANDROID_API=21

# Override example:
#   ANDROID_API=23 ./build_android.sh
ANDROID_API="${ANDROID_API:-$DEFAULT_ANDROID_API}"
CLEAN_BUILD=1

usage() {
  cat <<EOF
Usage: $0 [options] [ndk_path]

Options:
  --ndk <path>     Android NDK path
  --clean          Remove android-build/ and build-android/ before building (default)
  --no-clean       Do not remove previous build outputs
  -h, --help       Show this help

NDK resolution order:
  1) --ndk <path>
  2) ANDROID_NDK_HOME
  3) positional ndk_path
  4) DEFAULT_NDK_PATH ($DEFAULT_NDK_PATH) if it exists
EOF
}

NDK="${ANDROID_NDK_HOME:-}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --ndk)
      shift
      if [ "$#" -eq 0 ]; then
        echo "ERROR: --ndk requires a path."
        usage
        exit 2
      fi
      NDK="$1"
      shift
      ;;
    --clean)
      CLEAN_BUILD=1
      shift
      ;;
    --no-clean)
      CLEAN_BUILD=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      # Backward compatible: allow a single positional NDK path.
      if [ -z "$NDK" ] && [ -d "$1" ]; then
        NDK="$1"
        shift
      else
        echo "ERROR: Unknown argument '$1'"
        usage
        exit 2
      fi
      ;;
  esac
done

if [ -z "$NDK" ] && [ -d "$DEFAULT_NDK_PATH" ]; then
  NDK="$DEFAULT_NDK_PATH"
fi

if [ -z "$NDK" ]; then
  echo "ERROR: Set ANDROID_NDK_HOME or pass the NDK path as the first argument."
  echo "       Or install an NDK at: $DEFAULT_NDK_PATH"
  exit 1
fi

if [ ! -d "$NDK" ]; then
  echo "ERROR: NDK path '$NDK' not found."
  exit 1
fi

if [ "$CLEAN_BUILD" -eq 1 ]; then
  rm -rf android-build build-android
fi

if [[ "$(uname -s)" == "Darwin"* ]]; then
  HOST_TAG=darwin-x86_64
else
  HOST_TAG=linux-x86_64
fi

TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/$HOST_TAG"
if [ ! -d "$TOOLCHAIN" ]; then
  echo "ERROR: Expected toolchain at $TOOLCHAIN (check your NDK layout)."
  exit 1
fi

SYSROOT="$TOOLCHAIN/sysroot"
CORES=$(getconf _NPROCESSORS_ONLN || echo 4)
REPO_ROOT=$(pwd)
PREFIX_BASE=$REPO_ROOT/android-build

ABIS=(arm64 armv7)

for ABI in "${ABIS[@]}"; do
  case $ABI in
    arm64)
      API="$ANDROID_API"
      TRIPLE=aarch64-linux-android
      HOST=aarch64-linux-android
      EXTRA_CFLAGS=""
      PREFIX="$PREFIX_BASE/arm64-v8a"
      ;;
    armv7)
      API="$ANDROID_API"
      TRIPLE=armv7a-linux-androideabi
      HOST=armv7a-linux-androideabi
      EXTRA_CFLAGS="-mfloat-abi=softfp -mfpu=neon -march=armv7-a"
      PREFIX="$PREFIX_BASE/armeabi-v7a"
      ;;
    *)
      echo "Unknown ABI: $ABI"
      exit 1
      ;;
  esac

  CC="$TOOLCHAIN/bin/${TRIPLE}${API}-clang"
  CXX="$TOOLCHAIN/bin/${TRIPLE}${API}-clang++"
  AR="$TOOLCHAIN/bin/llvm-ar"
  RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
  # x264's makefiles may try to run STRIP on intermediate relocatable .o files
  # (not always safe with LLVM strip, can error on symbols referenced by relocations).
  # Disable stripping during the build; optionally strip the final installed archive later.
  STRIP=:
  STRIP_TOOLCHAIN="$TOOLCHAIN/bin/llvm-strip"

  if [ ! -x "$CC" ]; then
    echo "ERROR: clang not found at $CC"
    exit 1
  fi

  export CC CXX AR RANLIB STRIP

  CFLAGS="--sysroot=$SYSROOT $EXTRA_CFLAGS -O3 -fPIC -D__ANDROID_API__=$API"
  LDFLAGS="--sysroot=$SYSROOT"

  SRC_COPY=build-android/src-$ABI
  echo "Preparing source copy at $SRC_COPY"
  rm -rf "$SRC_COPY"
  mkdir -p "$SRC_COPY"

  # Copy repository into per-ABI source directory (exclude build outputs)
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --exclude 'android-build' --exclude 'build-android' --exclude '.git' "$REPO_ROOT/" "$SRC_COPY/"
  else
    (cd "$REPO_ROOT" && tar cf - .) | (cd "$SRC_COPY" && tar xf -)
  fi

  pushd "$SRC_COPY" > /dev/null

  echo "Configuring x264 (in-tree) for ABI=$ABI (API=$API) -> prefix=$PREFIX"
  export CC CXX AR RANLIB STRIP
  CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" \
    ./configure --host="$HOST" --sysroot="$SYSROOT" --prefix="$PREFIX" \
      --enable-pic --enable-static --disable-cli

  make -j"$CORES"
  make install

  if [ -f "$PREFIX/lib/libx264.a" ]; then
    "$STRIP_TOOLCHAIN" -S "$PREFIX/lib/libx264.a" || true
  fi

  popd > /dev/null
  echo "Built and installed to $PREFIX (source copy: $SRC_COPY)"
done

echo "All done. Artifacts are under: $PREFIX_BASE"
