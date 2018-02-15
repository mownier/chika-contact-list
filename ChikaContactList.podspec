Pod::Spec.new do |s|
  s.name     = 'ChikaUI'
  s.version  = '0.0.1'
  s.summary  = 'Custom UI for Chika'
  s.platform = :ios, '11.0'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'https://github.com/mownier/chika-ui'
  s.author   = { 'Mounir Ybanez' => 'rinuom91@gmail.com' }
  s.source   = { :git => 'https://github.com/mownier/chika-ui.git', :tag => s.version.to_s }
  s.source_files = 'ChikaUI/Source/*.swift'
  s.requires_arc = true
  
  s.dependency 'ChikaAssets'
end
