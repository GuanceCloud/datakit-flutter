#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ft_mobile_agent_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ft_mobile_agent_flutter'
  s.version          = '0.0.2'
  s.summary          = '基于观测云 ios android 调用的 plugin'
  s.description      = <<-DESC
基于观测云 ios android 调用的 plugin
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'FTMobileSDK/FTMobileAgent', "1.4.9-beta.4"
  s.ios.deployment_target = '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
