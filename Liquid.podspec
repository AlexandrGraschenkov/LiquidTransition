Pod::Spec.new do |s|
  s.name         = "Liquid"
  s.version      = "1.0.0"
  s.summary      = "Animated transitions make simple"
  s.description  = <<-DESC
                    Liquid helps to you build transition between view controllers. 
                    You still perform animation like before and have full manual acces for animation.
                    Liqud 
                   DESC

  s.homepage     = "https://github.com/AlexandrGraschenkov/LiquidTransition"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "Alexander Graschenkov" => "alexandr.graschenkov91@gmail.com" }
  s.platform     = :ios, "8.0"
  s.swift_version = '4.2'

  s.source       = { :git => "https://github.com/AlexandrGraschenkov/LiquidTransition.git", :tag => "#{s.version}" }
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.source_files  = "Liquid/**/*.{swift}"
end
