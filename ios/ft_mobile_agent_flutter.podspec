#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ft_mobile_agent_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ft_mobile_agent_flutter'
  s.version          = '0.0.2'
  s.summary          = 'Plugin based on TrueWatch iOS Android'
  s.description      = <<-DESC
Plugin based on TrueWatch iOS Android
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Copyright 2025 TRUEWATCH TECHNOLOGY INC PTE. LTD.' => 'brandonzhangdev@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'FTMobileSDK/FTMobileAgent', "1.5.17"
  s.ios.deployment_target = '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
