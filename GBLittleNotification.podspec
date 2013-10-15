Pod::Spec.new do |s|
  s.name         = "GBLittleNotification"
  s.version      = "1.0.1"
  s.summary      = "Little library for showing transient in-app popups. Supports fully customisable animations, styling and interactions."
  s.homepage     = "https://github.com/lmirosevic/GBLittleNotification"
  s.license      = 'Apache License, Version 2.0'
  s.author       = { "Luka Mirosevic" => "luka@goonbee.com" }
  s.platform     = :ios, '5.0'
  s.source       = { :git => "https://github.com/lmirosevic/GBLittleNotification.git", :tag => "1.0.1" }
  s.source_files  = 'GBLittleNotification'
  s.public_header_files = 'GBLittleNotification/GBLittleNotification.h'
  s.requires_arc = true
end
