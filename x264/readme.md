# 该脚本功能是在 M1 mac 下编译 macos 平台的 x264 静态库（arm64 和 x86_64）, 通过 lipo 生成通用静态库
## 关于host指定，参考 https://opensource.apple.com/source/gdb/gdb-1518/Makefile.auto.html

- i386-apple-darwin 
- x86_64-apple-darwin
- arm-apple-darwin

## 关于deployment target 的指定, 参考 https://github.com/llvm-mirror/clang/blob/master/include/clang/Driver/Options.td

- `-mmacosx-version-min=`
- `-mios-simulator-version-min=`
- `-mios-version-min=`

# iOS版本编译
参考： https://github.com/kewlbear/x264-ios
