# build soundtouch for ios

## skip code signing

```
-DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO
```

## use int sample format instead of float

```
-DINTEGER_SAMPLES=ON
```
## how to use soundtouch

```
初始化
m_soundTouch.setSampleRate(44100);
m_soundTouch.setChannels(2);

设置新速度
m_soundTouch.setTempo(new_speed);

m_soundTouch.setPitch(1.);
m_soundTouch.setRate(1.);
```


- [SoundTouch是什么](https://github.com/bamboolife/SoundTouch?tab=readme-ov-file)
- [音视频系列九 使用soundTouch实现音视频变速](https://blog.csdn.net/Welcome_Word/article/details/124434675)