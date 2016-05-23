Pod::Spec.new do |s|
  s.name         = "ODObjCRuntime"
  s.version      = "1.2.1"
  s.summary      = "ObjC wrapper for working with ObjC Runtime functions."
  s.homepage     = "https://github.com/Rogaven/ODObjCRuntime"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "Alexey Nazaroff" => "alexx.nazaroff@gmail.com" }
  s.source       = { :git => "https://github.com/Rogaven/ODObjCRuntime.git", :tag => s.version.to_s }
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.6'
  s.watchos.deployment_target = '1.0'
  s.source_files = 'src/**/*'
  s.requires_arc = true
end
