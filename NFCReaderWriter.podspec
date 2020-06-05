Pod::Spec.new do |s|
  s.name             = 'NFCReaderWriter'
  s.version          = '1.0.5'
  s.summary          = 'NFCReaderWriter which supports to read data from NFC chips(iOS 11) and write data to NFC chips(iOS 13) by iOS devices. Compatible with both Swift and Objective-C.'
 
  s.homepage         = 'https://github.com/janlionly/NFCReaderWriter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'janlionly' => 'janlionly@gmail.com' }
  s.source           = { :git => 'https://github.com/janlionly/NFCReaderWriter.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/janlionly'
  s.ios.deployment_target = '11.0'
  s.requires_arc = true
  s.source_files = 'Sources/NFCReaderWriter/*.{h,m}'
  s.frameworks = 'CoreNFC'
  s.swift_versions = ['4.2', '5.0', '5.1', '5.2']
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }
end
