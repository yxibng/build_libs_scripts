# webrtc 3A 算法

webrtc 发布版本地址 https://chromiumdash.appspot.com/branches
- 编译使用的版本是 91，分支是 `branch-heads/4472`


## webrtc 代码获取

- 依赖 [Chromium depot_tools](https://webrtc.github.io/webrtc-org/native-code/development/prerequisite-sw/)

[install on Linux / Mac](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)

```
$ git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
```

添加环境变量 `.zshrc`

```
# depot_tools
export PATH=/path/to/depot_tools:$PATH

# 例如
# export PATH="$HOME/Tools/depot_tools:$PATH"
```

[fetch source code](https://webrtc.github.io/webrtc-org/native-code/ios/)

```
fetch --nohooks webrtc_ios
gclient sync
```

## 编译步骤

 官方编译参考：https://webrtc.github.io/webrtc-org/native-code/ios/

 编译脚本： 
 - 模块化编译：https://github.com/Nemocdz/WebRTC-Hack
 - 整体编译参考： https://github.com/webrtc-sdk/webrtc-build/blob/main/docs/build.md


遇到签名问题解决方案




1. 克隆代码，见上面步骤
2. 切换到 branch-heads/4472
   - 进入到 `src` 目录， 执行 `git checkout branch-heads/4472`
3. 同步代码
    - 进入 src 上级目录，执行 `gclient sync`
4. 修改配置


> src/modules/audio_processing/BUILD.gn

```
rtc_library("audio_processing") {
  complete_static_lib = true  # 添加这一行
  visibility = [ "*" ]
  configs += [ ":apm_debug_dump" ]
  sources = [

```


解决签名问题, 执行命令，获取签名列表

```
➜  /Users/yxibng/Desktop/libs security find-identity -v -p codesigning
  1) 07EDFF5AAC6AF28362F4C4F127F70EB9525B849E "Apple Development: xiaobing yao (JR9UX7L93X)"
  2) DE6A448E9A99CAE6FC3B3A6D4545713E096E5160 "Apple Development: xiaobing yao (24ZM6UP2MW)"
  3) 90DFF2E2F97A180945BE97F18D89B99E6A81128B "Apple Development: xiaobing yao (9PCZ6DYF2S)"
     3 valid identities found
```


> src/build/config/ios/ios_sdk.gni

替换签名

```
-  ios_code_signing_identity = ""
+  ios_code_signing_identity = "Apple Development: xiaobing yao (24ZM6UP2MW)"

-  ios_code_signing_identity_description = "Apple Development"
+  ios_code_signing_identity_description = ""

```


将 webrtc_iOS_module_build.sh 放进 src 目录， 执行

```
sh webrtc_iOS_module_build.sh ./modules/audio_processing  `pwd`/output
```

生成物 `audio_processing.xcframework`













