Pod::Spec.new do |s|
  s.name             = 'VLensLib'
  s.version          = '1.5.1'
  s.summary          = 'VLens iOS SDK for digital identity verification.'
  s.description      = <<-DESC
    VLens iOS SDK enables digital identity verification in iOS apps:
    national ID capture (front and back), face liveness detection, and face matching.
    Supports both SwiftUI and UIKit integration.
  DESC

  s.homepage         = 'https://github.com/Vlens2021/vlens-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'VLens' => 'mhamed@vlenseg.com' }
  s.source           = { :git => 'https://github.com/Vlens2021/vlens-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version         = '5.5'

  s.source_files = 'Sources/VLensLib/**/*.swift'

  s.resource_bundles = {
    'VLensLib' => [
      'Sources/Resources/**/*',
      'Sources/VLensLib/Localization/en.lproj',
      'Sources/VLensLib/Localization/ar.lproj'
    ]
  }

  s.frameworks = 'ARKit', 'AVFoundation', 'UIKit'

  s.dependency 'Alamofire',    '~> 5.7'
  s.dependency 'DatadogCore',  '~> 2.14'
  s.dependency 'DatadogLogs',  '~> 2.14'
  s.dependency 'DatadogRUM',   '~> 2.14'
end
