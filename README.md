# WuKongIMSDK

对悟空IM协议的封装和消息的处理

## 文档

http://githubim.com/sdk/i-os

## xcodebuild 打包 （生成的文件在Example/build下）

构建模拟器文件

xcodebuild BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS="-fembed-bitcode" -project '_Pods.xcodeproj' -target 'WuKongIMSDK' -sdk iphonesimulator


// 生成真机文件

xcodebuild BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS="-fembed-bitcode" -project '_Pods.xcodeproj' -target 'WuKongIMSDK' -sdk iphoneos

// 合并模拟器和真机

lipo -create ./Example/build/Release-iphonesimulator/WuKongIMSDK/WuKongIMSDK.framework/WuKongIMSDK  ./Example/build/Release-iphoneos/WuKongIMSDK/WuKongIMSDK.framework/WuKongIMSDK  -output WuKongIMSDKLib

获得 WuKongIMSDKLib文件 改名为WuKongIMSDK 替换WuKongIMSDK.framework内的WuKongIMSDK

注意： 如果有编译错误信息 进入到 Example目录 执行pod install 然后再执行打包命令

错误整理：

Could not find module for target 'x86_64-apple-ios-simulator'

需要将模拟器的WuKongIMSDK.framework/Modules/WuKongIMSDK.swiftmodule下的文件跟真机的合并
