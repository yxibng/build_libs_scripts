
## 依赖
- exiv2 (v0.27.7): https://github.com/exiv2/exiv2
- libexpat(2.6.2): https://github.com/libexpat/libexpat

## NDK 版本
- 21.4.7075529
- DANDROID_PLATFORM=android-21

## 编译 arm64-v8a, armeabi-v7a 静态库
- 先编译 libexpat，再编译 exiv2, exiv2 依赖 libexpat 

## 编译脚本
1. 设置环境变量
```
# android studio ndk
export ANDROID_NDK=$ANDROID_SDK_ROOT/ndk/21.4.7075529

#java home 
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-1.8.jdk/Contents/Home
```

2. 下载 exiv2(v0.27.7) 源码
```
wget https://github.com/exiv2/exiv2/archive/refs/tags/v0.27.7.tar.gz
tar -xzf v0.27.7.tar.gz
mv exiv2-0.27.7 exiv2
```
3. 拷贝 script 里面的文件到 exiv2 目录下
4. 编译 libexpat
```
cd exiv2
./build_expat_android.sh arm64-v8a
./build_expat_android.sh armeabi-v7a
```
5. 编译 exiv2
```
./build_exiv2_android.sh arm64-v8a
./build_exiv2_android.sh armeabi-v7a
```
6. 验证编译结果
```
ls -la libs/arm64-v8a/
ls -la libs/armeabi-v7a/
```
## 注意链接问题, cmake 中使用如下

```
target_link_libraries(${PROJECT_NAME}
    PRIVATE
    android
    log
    "-Wl,--start-group"
    expat
    exiv2
    exiv2-xmp
    "-Wl,--end-group"
)
```






