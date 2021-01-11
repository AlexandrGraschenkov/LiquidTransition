# LiquidTransition &nbsp; [![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Amazing%20library%20for%20iOS%20animated%20transitions&url=https://github.com/AlexandrGraschenkov/LiquidTransition)

[![Cocoapods](https://img.shields.io/badge/Cocoapods-Compatible-brightgreen.svg?style=flat)](https://cocoapods.org)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
[![Version](https://img.shields.io/cocoapods/v/LiquidTransition.svg?style=flat)](https://cocoapods.org/pods/LiquidTransition)
![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg)
[![License](https://img.shields.io/cocoapods/l/LiquidTransition.svg?style=flat)](https://github.com/AlexandrGraschenkov/LiquidTransition/blob/master/LICENSE.txt)
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://paypal.me/gralexdev)

LiquidTransition provide new API for transition creation. 

Features: 
* Easy and convinient API (less boilerplate code)
* Animate backward
* Interrupt transition at any time to continue interactive
* Helper class for restore views state
* Animation of custom properties *(or `CALayer` properties)*
* Complex transition without 'lag'

![Web browser](/../screenshots/gif/web_browser.gif?raw=true "Web browser") &nbsp;
![Photo browser](/../screenshots/gif/photo_browser.gif?raw=true "Photo browser") &nbsp;
![Complex animation](/../screenshots/gif/complex_animation.gif?raw=true "Complex animation")

## Instalation

### CocoaPods

Add the following entry to your Podfile:

```rb
pod 'LiquidTransition'
```

Then run `pod install`.

Don't forget to `import LiquidTransition` in every file you'd like to use LiquidTransition.

## Usage

Like this you can create simple transition
``` Swift
import LiquidTransition

class FadeTransition: Animator<FromViewController, ToViewController> {

    init() {
        super.init(from: FromViewController.self, to: ToViewController.self, direction: .both)
        
        duration = 0.3
        timing = Timing.default
        // do not perform here complex operations, cause it calls on app initialization
    }
    
    override func animation(src: FromViewController, dst: ToViewController, container: UIView, duration: Double) {
        dst.view.alpha = 0
        
        // perform linear animation and manage timing function with `self.timing`
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            dst.view.alpha = 1
        }) { _ in
            dst.view.alpha = 1 // if anim somehow canceled
        }
    }
}
```

On app starts you can setup transitions
``` Swift
Liquid.shared.becomeDelegate() // Liquid automaticly becomes delegates for all animated transitions
Liquid.shared.addTransitions([FadeTransition()])
```

That's it! Easy enought?! :)

#### Customization

```Swift
import LiquidTransition

class ExampleTransition: Animator<SampleController, CardsNavigationController> {

    var imgView: UIImageView!
    init() {
        super.init(from: SampleController.self, to: CardsNavigationController.self, direction: .both)
        
        duration = 0.4
        timing = Timing.init(closure: { $0 * $0 })
        
        addCustomAnimation {[weak self] (progress) in
            self?.imgView?.layer.cornerRadius = 20 * (1-progress)
        }
    }
    
    override func animation(src: SampleController, dst: CardsNavigationController, container: UIView, duration: Double) {
        imgView = dst.imgView
        
        // this class restore all views state before transition
        // when you have lot of property changes, it can be might helpfull
        let restore = TransitionRestorer()
        restore.addRestore(imgView, src.fadeView)
        
        // cause on end transition we dont want restore superview of `src.view` and `dst.view`
        restore.addRestore(dst.view, ignoreFields: [.superview])
        
        dst.view.alpha = 0
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            dst.view.alpha = 1
            src.fadeView.alpha = 0
            self.imgView.frame = CGRect(/*new frame*/)
        }) { _ in
            restore.restore()
        }
    }
}
```

Sometimes we need that one transition work for multiple controllers. In this case you can define `UIViewController` as template classes and call init method with multiple classes defined:

```Swift
class FadeTransition: Animator<UIViewController, UIViewController> {

init() {
    super.init(from: [VC1.self, VC2.self, VC3.self], to: [VC4.self, VC5.self], direction: .both)
    duration = 0.3
}

override func animation(src: UIViewController, dst: UIViewController, container: UIView, duration: Double) {
// animation
}
```

Or use protocol, to have access to common views. If it's not your case, you can ovverride `canAnimate` function
```Swift
open func canAnimate(src: UIViewController, dst: UIViewController, direction animDirection: Direction) -> Bool
```
and define your conditions

## TODO

- [x] Backward animation
- [x] Custom timing function
- [x] Allow custom animation
- [x] Restore view state helper class
- [x] Smooth interactive animation for complex prepare animation
- [x] Support Cocoapods
- [ ] Support Carthage
- [x] Add custom save keys for `TransitionRestorer`
- [ ] Add some default animations

## Notes

LiquidTransition controls animation percent completion. So if you define animation in one direction, it can run animation backward. In backward animation run from 1 to 0. So if you works with `NSNavigationController` with `navigationBar`, you can see that `navigationBar` animates backward (see example with photos). In this case better to define animation in both directions.

LiquidTransition 'inspired' by [Hero](https://github.com/HeroTransitions/Hero). We have complex UI with custom animation. Several weaks we try to implement performance animation in `Hero`. When nothing works with `Hero`, we check manual implementation of transition. It works much faster. Cause `Hero` do a lot of snapshots, performs transition becomes laggy. In real project `Hero` showed not enough performance and require a lot of code to say what you really want. So in real app manual transition looks more suitable. `Hero` was removed from project and we move to transitions with manual control. Some pieces of new library start appear in our project. Now some ideas and code was moved and refactored for common usage in one library.

If you look for something similar, take a look on [Transition](https://github.com/Touchwonders/Transition) and [EasyTransitions](https://github.com/marcosgriselli/EasyTransitions). I found this projects after finish `LiquidTransition` and they have good ideas behind. They less convenient, but still good lib.

## Credits

Alexandr Graschenkov: alexandr.graschenkov91@gmail.com <br>
`iOS` and `Computer Vision` developer
