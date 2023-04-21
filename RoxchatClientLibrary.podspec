Pod::Spec.new do |s|

  s.name = 'RoxchatClientLibrary'
  s.version = '3.0.2'
  
  s.author = { 'RoxChat Ltd.' => 'dev@rox.chat' }
  s.homepage = 'https://rox.chat'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Rox.chat client SDK for iOS.'
  
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.source = { :git => 'https://github.com/roxchat/mobile-sdk-ios', :tag => s.version.to_s }
  
  s.dependency 'SQLite.swift', '0.13.3'
  s.frameworks = 'Foundation'
  s.source_files = 'RoxchatClientLibrary/**/*'

end
