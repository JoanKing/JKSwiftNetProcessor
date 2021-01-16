#
# Be sure to run `pod lib lint JKSwiftNetProcessor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JKSwiftNetProcessor'
  s.version          = '0.1.1'
  s.summary          = '这是一个简单的网络请求库'
  s.description      = 'JKSwiftNetProcessor 主要是封装了Alamofire、HandyJSON、CryptoSwift的库'

  s.homepage         = 'https://github.com/JoanKing/JKSwiftNetProcessor'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JoanKing' => 'chongwang27@creditease.cn' }
  s.source           = { :git => 'https://github.com/JoanKing/JKSwiftNetProcessor.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.source_files = 'JKSwiftNetProcessor/Classes/**/*'
  
  # s.resource_bundles = {
  #   'JKSwiftNetProcessor' => ['JKSwiftNetProcessor/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Alamofire'
  s.dependency 'HandyJSON'
  s.dependency 'CryptoSwift'
  
end
