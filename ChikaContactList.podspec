Pod::Spec.new do |s|
  s.name     = 'ChikaContactList'
  s.version  = '0.0.1'
  s.summary  = 'Contact list feature of Chika'
  s.platform = :ios, '11.0'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'https://github.com/mownier/chika-contact-list'
  s.author   = { 'Mounir Ybanez' => 'rinuom91@gmail.com' }
  s.source   = { :git => 'https://github.com/mownier/chika-contact-list.git', :tag => s.version.to_s }
  s.source_files = 'ChikaContactList/Source/*.swift'
  s.resources = ['ChikaContactList/Source/ContactList.storyboard']
  s.requires_arc = true
  
  s.dependency 'ChikaFirebase/Query:Contact'
  s.dependency 'ChikaFirebase/Listener:Presence'

  s.dependency 'ChikaUI'
  s.dependency 'ChikaAssets'
end
