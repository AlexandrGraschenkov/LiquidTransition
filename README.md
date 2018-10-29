# LiquidTransition


[![Cocoapods](https://img.shields.io/badge/Cocoapods-Compatible-brightgreen.svg?style=flat)](https://cocoapods.org)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
[![Version](https://img.shields.io/cocoapods/v/LiquidTransition.svg?style=flat)](https://cocoapods.org/pods/LiquidTransition)
![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg)
[![License](https://img.shields.io/cocoapods/l/LiquidTransition.svg?style=flat)](https://github.com/AlexandrGraschenkov/LiquidTransition/blob/master/LICENSE.txt)
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://paypal.me/gralexdev)

This library created for review a way of creation transition between view controllers. 
LiquidTransition provide new API for transition creation. 
- Now you don't need to create separate animation class, percent transition controller and correctly connect all together to perform transition animation. 
- You don't think about how propertly cancel animation.
- The way you perform animation still same.

![Web browser](/../screenshots/gif/web_browser.gif?raw=true "Web browser")<br>
![Photo browser](/../screenshots/gif/photo_browser.gif?raw=true "Photo browser")<br>
![Complex animation](/../screenshots/gif/complex_animation.gif?raw=true "Complex animation")

## Instalation

### CocoaPods

Add the following entry to your Podfile:

```rb
pod 'LiquidTransition'
```

Then run `pod install`.

Don't forget to `import Liquid` in every file you'd like to use LiquidTransition.

## Usage

On app starts you can setup transitions
``` Swift
Liquid.shared.becomeDelegate() // Liquid automaticly becomes delegates for all animated transitions
Liquid.shared.addTransitions([FadeTransition()])
```
Like this you can create simple transition
``` Swift
import Liquid

class FadeTransition: TransitionAnimator<UIViewController, CardsNavigationController> {

    init() {
        super.init(from: UIViewController.self, to: CardsNavigationController.self, direction: .both)
        
        duration = 0.3
        timing = Timing.default
        // do not perform here complex operations, cause it calls on app initialization
    }
    
    override func animation(vc1: UIViewController, vc2: UIViewController, container: UIView, duration: Double) {
        vc2.view.alpha = 0
        
        // perform linear animation and manage timing function with `self.timing`
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            vc2.view.alpha = 1
        }) { _ in
            vc2.view.alpha = 1 // if anim somehow canceled
        }
    }
}
```
That it! Easy enought?! :)

Also there some advantages over standart approach:
- You don't need to write boilerplate code for animation transition setup
- You have more easy control on timing function `transtion.timing`
- You don't need to write boiletplate code for backward animation (**less code by 2 times**)
- You can animate not animatable properties (like `cornerRadius` or watewer you want, look at `transtion.addCustomAnimation(...)`)

#### Example customization

```Swift
import Liquid

class ExampleTransition: TransitionAnimator<SampleController, CardsNavigationController> {

    var imgView: UIImageView!
    init() {
        super.init(from: SampleController.self, to: CardsNavigationController.self, direction: .both)
        
        duration = 0.4
        timing = Timing.init(closure: { $0 * $0 })
        
        addCustomAnimation {[weak self] (progress) in
            self?.imgView?.layer.cornerRadius = 20 * (1-progress)
        }
    }
    
    override func animation(vc1: SampleController, vc2: CardsNavigationController, container: UIView, duration: Double) {
        imgView = vc2.imgView
        
        // this class restore all views state before transition
        // when you have lot of property changes, it can be might helpfull
        let restore = RestoreTransition()
        restore.addRestore(imgView, vc1.fadeView)
        
        // cause on end transition we dont want restore superview of `vc1.view` and `vc2.view`
        restore.addRestore(vc2.view, ignoreFields: [.superview])
        
        vc2.view.alpha = 0
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            vc2.view.alpha = 1
            vc1.fadeView.alpha = 0
            self.imgView.frame = CGRect(/*new frame*/)
        }) { _ in
            restore.restore()
        }
    }
}
```

## TODO

- [x] Backward animation
- [x] Custom timing function
- [x] Allow custom animation
- [x] Restore view state helper class
- [x] Support Cocoapods
- [ ] Support Carthage
- [x] Add custom save keys for `RestoreTransition`
- [ ] Add some default animations

## Notes

LiquidTransition controls animation percent completion. So if you define animation in one direction, it can run animation backward. In backward animation run from 1 to 0. So if you works with `NSNavigationController` with `navigationBar`, you can see that `navigationBar` animates backward (see example with photos). In this case better to define animation in both directions.

## Credits

Alexandr Graschenkov: alexandr.graschenkov91@gmail.com <br>
`iOS` and `Computer Vision` developer
