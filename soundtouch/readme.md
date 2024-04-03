# build soundtouch for ios

## skip code signing

```
-DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO
```

## use int sample format instead of float

```
-DINTEGER_SAMPLES=ON
```

in your code, define `SOUNDTOUCH_INTEGER_SAMPLES`

```
#define SOUNDTOUCH_INTEGER_SAMPLES 1
#include "soundtouch/SoundTouch.h"
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


## 注意

双声道，每个声道包含 1 个采样。numInputSamples 计算的时候每个采样包含左右声道的采样。

```
// Number of samples in buffer.
// Notice that in case of stereo-sound a single sample contains data for both channels.
pSoundTouch->putSamples(inputSampleBuffer, numInputSamples);
```

多次读取，直到读完

```
pSoundTouch->putSamples(inputSampleBuffer, numInputSamples);

do
{
    SAMPLETYPE sampleBuffer[BUFF_SIZE];
    int buffSizeSamples = BUFF_SIZE / nChannels;

    nSamples = pSoundTouch->receiveSamples(sampleBuffer, buffSizeSamples);
    UseReadySound(sampleBuffer, nSamples * nChannels);
} while (nSamples != 0);
```


