# opus


- 版本 1.3.1, https://opus-codec.org/release/stable/2019/04/12/libopus-1_3_1.html
- git 地址 https://github.com/xiph/opus
- 使用 cmake 来编译， 依赖 cmake 工具链 [ios.toolchain.cmake](https://github.com/leetal/ios-cmake)
    -  目录下有一个 ios.toolchain.cmake，可以直接使用

编译步骤

1. 下载 opus 1.3.1 源码
2. 将 `ios.toolchain.cmake` ,  `opus_buildtype.cmake` 和 `build_opus.sh` 放进解压后的目录
3. 执行 `./build_opus.sh `
4. 生成物为 `opus.xcframework`