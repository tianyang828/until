#
#  Be sure to run `pod spec lint test1.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
	s.name         = "until"
	s.version      = "0.0.1"
	s.summary      = "测试创建sdk"
	s.description  = <<-DESC
	"描述不为空"
	DESC

	s.homepage     = "https://github.com/tianyang828"
	s.license      = { :type => "MIT", :file => "LICENSE" }
	s.author             = { "tianyang" => "tianyang6916@163.com" }
	#s.platform     = :ios, "8.0"
	s.source       = { :git => "https://github.com/tianyang828/until.git", :tag => "#{s.version}" }
	s.source_files  = 'until/**/*'
	s.public_header_files = 'until/**/*.h'

end
