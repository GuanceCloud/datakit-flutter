#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ft_mobile_agent_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ft_mobile_agent_flutter'
  s.version          = '0.0.2'
  s.summary          = 'Plugin based on Guance Cloud iOS Android'
  s.description      = <<-DESC
Plugin based on Guance Cloud iOS Android
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Shanghai Guance Information Technology Co.,Ltd' => 'zhangbo@guance.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'FTMobileSDK/FTMobileAgent', "1.6.3"
  s.dependency 'FTMobileSDK/FTSessionReplay', "1.6.3"
  s.ios.deployment_target = '12.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
