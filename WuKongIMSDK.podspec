#
# Be sure to run `pod lib lint WuKongIMSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WuKongIMSDK'
  s.version          = '1.0.0'
  s.summary          = 'A short description of WuKongIMSDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/WuKongIM/WuKongIMiOSSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tangtaoit' => 'tt@tgo.ai' }
  s.source           = { :git => "https://github.com/WuKongIM/WuKongIMiOSSDK.git" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.platform     = :ios, '12.0'
  s.requires_arc = true
  
  s.ios.deployment_target = '12.0'
  
  #   s.xcconfig = { 'LIBRARY_SEARCH_PATHS' => '${PODS_ROOT}/LiMaoBase/Classes/Vendor/arm/lib' }
  ## xcode12.0 上 这里如果注释掉用s.vendored_libraries会报  have the same architectures (arm64) and can't be in the same fat output file 错误
  ##
# s.xcconfig = { 'LIBRARY_SEARCH_PATHS' => '/Users/tt/work/projects/limao/ios/LiMaoIMiOSSDK/WuKongIMSDK/Classes/private/arm/lib' }
  
  ## 打包framework的时候需要把vendored_libraries注释掉 然后打开s.xcconfig
    s.vendored_libraries = 'WuKongIMSDK/Classes/private/arm/lib/*.a'
  
  s.preserve_paths = 'WuKongIMSDK/Classes/private/arm/lib/*.a','WuKongIMSDK/Classes/private/curve25519/ed25519/**/*.{c,h}'
  s.libraries = 'opencore-amrnb', 'opencore-amrwb','vo-amrwbenc'

  s.source_files = 'WuKongIMSDK/Classes/**/*'
  s.public_header_files =  'WuKongIMSDK/Classes/**/*.h'
  s.private_header_files = 'WuKongIMSDK/Classes/private/**/*.h'
  s.frameworks = 'UIKit', 'MapKit', 'Security'
  s.swift_version = '5.0'
#  s.xcconfig = {
#      'ENABLE_BITCODE' => 'NO',
#      "OTHER_LDFLAGS" => "-ObjC"
#  }
  
  s.resource_bundles = {
    'WuKongIMSDK' => ['WuKongIMSDK/Assets/*.png','WuKongIMSDK/Assets/Migrations/*']
  }
  
  s.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
      'DEFINES_MODULE' => 'YES'
    }
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }


  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'CocoaAsyncSocket', '~> 7.6.4'
#  s.dependency 'FMDB', '~>2.7.5'
  s.dependency 'FMDB/SQLCipher', '~>2.7.5'
  s.dependency '25519', '~>2.0.2'
  s.dependency 'libsignal-protocol-c'
#  s.dependency 'LibSignalProtocolSwift'
end