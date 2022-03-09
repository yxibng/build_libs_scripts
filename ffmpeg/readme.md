# 脚本是在 M1 mac 下编译 macos 平台下的ffmpeg 静态库
- 支持arm64 和 x86_64
- 链接到自己编译的libx264, 需要指定libx264库的路径

# 关于编译带调试符号的ffmpeg静态库
参考： [如何高效的调试 ffmpeg](https://dongyadoit.com/ffmpeg/2020/05/24/how-to-debug-ffmpeg-effectively/)

关键配置：
 --enable-debug=LEVEL是用来控制编译器比如gcc的debug level选项的，不是控制ffmpeg的debug level选项的；
参考：  https://gcc.gnu.org/onlinedocs/gcc/Debugging-Options.html
>Request debugging information and also use level to specify how much information. The default level is 2.

>Level 0 produces no debug information at all. Thus, -g0 negates -g.

>Level 1 produces minimal information, enough for making backtraces in parts of the program that you don’t plan to debug. This includes descriptions of functions and external variables, and line number tables, but no information about local variables.

>Level 3 includes extra information, such as all the macro definitions present in the program. Some debuggers support macro expansion when you use -g3.

遇到的问题及参考：
1. clang is unable to create an executable file. C compiler test failed.
    编译arm64的ffmpeg时，指定了`--cpu=arm64`， 报了这个错，去掉后不报错。参考了https://blog.csdn.net/u012459903/article/details/119104966
2. m1 mac 交叉编译生成 x86_64 ffmpeg, 参考了 https://python.iitter.com/other/241151.html
3. 官方的编译说明 https://trac.ffmpeg.org/wiki/CompilationGuide
4. [ffmpeg-on-apple-silicon](https://github.com/ssut/ffmpeg-on-apple-silicon)

# 交叉编译 iOS 平台的ffmpeg 静态库
参考： https://github.com/kewlbear/FFmpeg-iOS-build-script
