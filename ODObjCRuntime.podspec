Pod::Spec.new do |s|
  s.name         = "ODObjCRuntime"
  s.version      = "1.0.0"
  s.summary      = "ObjC wrapper for working with ObjC Runtime functions."
  s.homepage     = "https://github.com/Rogaven/ODObjCRuntime"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "Alexey Nazaroff" => "alexx.nazaroff@gmail.com" }
  s.source       = { :git => "https://github.com/Rogaven/ODObjCRuntime.git", :tag => s.version.to_s }
  s.platform     = :ios, '5.0'
  s.source_files = 'src/**/*'
  s.requires_arc = true
end
