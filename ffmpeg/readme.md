# 脚本是在 M1 mac 下编译 macos 平台下的ffmpeg 静态库
- 支持arm64 和 x86_64
- 链接到自己编译的libx264, 需要指定libx264库的路径

遇到的问题及参考：
1. clang is unable to create an executable file. C compiler test failed.
    编译arm64的ffmpeg时，指定了`--cpu=arm64`， 报了这个错，去掉后不报错。参考了https://blog.csdn.net/u012459903/article/details/119104966
2. m1 mac 交叉编译生成 x86_64 ffmpeg, 参考了 https://python.iitter.com/other/241151.html
3. 官方的编译说明 https://trac.ffmpeg.org/wiki/CompilationGuide
4. [ffmpeg-on-apple-silicon](https://github.com/ssut/ffmpeg-on-apple-silicon)