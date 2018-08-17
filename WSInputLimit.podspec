
Pod::Spec.new do |s|

s.name             = "WSInputLimit"
s.version          = "0.0.1"
s.summary          = "UITextView/UITextField Input Limit"
s.description  = <<-DESC
                    * 支持禁止emoji输入
                    * 支持最大可输入字符数量限制
                    * 支持限制仅输入数字
                    * 支持小数样式输入限制
                    * 支持小数点位数限制
                    DESC
s.homepage         = "https://github.com/ONECATYU/WSInputLimit"
s.license          = { :type => "MIT", :file => "LICENSE" }
s.author           = { "ONECATYU" => "786910875@qq.com" }
s.platform         = :ios, "8.0"
s.source           = { :git => "https://github.com/ONECATYU/WSInputLimit.git", :tag => s.version.to_s }
s.source_files     = "WSInputLimit", "WSInputLimit/**/*.{h,m}"
s.frameworks       = "UIKit", "Foundation"
s.requires_arc     = true

end
