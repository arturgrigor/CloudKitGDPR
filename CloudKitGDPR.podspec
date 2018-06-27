Pod::Spec.new do |s|
  s.name = 'CloudKitGDPR'
  s.version = '1.0.1'
  s.license = 'MIT'
  s.summary = 'Framework for allowing users to manage data stored in iCloud.'
  s.homepage = 'https://github.com/arturgrigor/CloudKitGDPR'
  s.social_media_url = 'http://twitter.com/arturgrigor'
  s.authors = { 'Artur Grigor' => 'arturgrigor@gmail.com' }
  s.source = { :git => 'https://github.com/arturgrigor/CloudKitGDPR.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '3.0'

  s.source_files = 'Sources/*.swift'

  s.requires_arc = true
end
