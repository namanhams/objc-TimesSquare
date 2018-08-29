Pod::Spec.new do |s|
  s.name                  = "TimesSquare"
  s.version               = "1.0"
  s.summary               = "Forked repo"
  s.description           = "N/A"
  s.homepage              = "https://github.com/namanhams/objc-TimesSquare"
  s.license               = { :type => "MIT", :file => "LICENSE" }
  s.author                = { "Pham Le" => "namanhams.le@gmail.com" }
  s.ios.deployment_target = "9.0"
  s.source                = { :git => "https://github.com/namanhams/objc-TimesSquare.git", :tag => s.version }
  s.requires_arc          = true
  s.source_files          = "*.h", "*.m"
end
