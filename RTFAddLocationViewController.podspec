Pod::Spec.new do |s|
  s.name         = "RTFAddLocationViewController"
  s.version      = "0.0.1"
  s.summary      = "A drop-in view controller for allowing the user to select a location. Contains place-autocompletion and geocoding."
  s.homepage     = "http://reactivefusion.co"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Max Kramer" => "max@maxkramer.co" }
  s.social_media_url   = "http://twitter.com/MaxKramer"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/MaxKramer/RTFAddLocationViewController.git", :tag => "v#{s.version}" }
  s.source_files  = "src/*.{h,m}"
  s.dependency "GoogleMaps"
  s.resources = ["src/RTFAddLocationViewController.xib"]
end
