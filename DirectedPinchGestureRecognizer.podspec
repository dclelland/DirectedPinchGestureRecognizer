#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name                    = "DirectedPinchGestureRecognizer"
  s.version                 = "1.0.0"
  s.summary                 = "DirectedPinchGestureRecognizer provides a more comprehensive pinch gesture API."
  s.homepage                = "https://github.com/dclelland/DirectedPinchGestureRecognizer"
  s.license                 = { :type => 'MIT' }
  s.author                  = { "Daniel Clelland" => "daniel.clelland@gmail.com" }
  s.source                  = { :git => "https://github.com/dclelland/DirectedPinchGestureRecognizer.git", :tag => "1.0.0" }
  s.platform                = :ios, '8.0'
  s.ios.deployment_target   = '8.0'
  s.ios.source_files        = 'DirectedPinchGestureRecognizer.swift'
  s.requires_arc            = true
end
