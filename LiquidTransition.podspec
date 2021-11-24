Pod::Spec.new do |s|
  s.name         = "LiquidTransition"
  s.version      = "1.2.1"
  s.summary      = "Animated transitions make simple"
  s.description  = <<-DESC
                    LiquidTransition helps to you build transition between view controllers. 
                    You still perform animation like before and have full manual acces for animation.
                    Liqud 
                   DESC

  s.homepage     = "https://github.com/AlexandrGraschenkov/LiquidTransition"
  # s.screenshots  = "https://github.com/AlexandrGraschenkov/LiquidTransition/raw/screenshots/gif/web_browser.gif", 
  #                  "https://github.com/AlexandrGraschenkov/LiquidTransition/raw/screenshots/gif/photo_browser.gif", 
  #                  "https://github.com/AlexandrGraschenkov/LiquidTransition/raw/screenshots/gif/complex_animation.gif"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "Alexander Graschenkov" => "alexandr.graschenkov91@gmail.com" }
  s.platform     = :ios, "8.0"
  s.swift_version = '5'

  s.source       = { :git => "https://github.com/AlexandrGraschenkov/LiquidTransition.git", :tag => "#{s.version}" }
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.ios.deployment_target  = '8.0'
  s.source_files  = "Liquid/**/*.{swift}"
end
