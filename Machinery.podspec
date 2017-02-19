#
#  Be sure to run `pod spec lint Machinery.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name = 'Machinery'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'Simple State Machine in Swift'
  s.homepage = 'https://github.com/salimbraksa/Machinery'
  s.authors = { 'Salim Braksa' => 'salim@hiddenfounders.com' }
  s.source = { :git => 'https://github.com/salimbraksa/Machinery', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'Machinery/*.swift'

end
