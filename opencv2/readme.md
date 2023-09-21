# opencv2

- [版本](https://opencv.org/releases/) OpenCV – 4.8.0
- git 地址 https://github.com/opencv/opencv
- 依赖 python, 使用 python3 调用命令会出错，解决方案，将 python 命令设置为 python3 命令的软连接

```
sudo ln -s /opt/homebrew/bin/python3   /opt/homebrew/bin/python
```

参考： [Build issues on M1 mac](https://github.com/opencv/opencv/issues/21926)


编译步骤， 参考 https://docs.opencv.org/4.x/d5/da3/tutorial_ios_install.html

1. 下载 OpenCV – 4.8.0 源码
2. 将 `build_opencv2.sh` 放进解压后的目录
3. 执行 `./build_opencv2.sh`
4. 生成物为 `opencv2.xcframework`