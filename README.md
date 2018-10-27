# LiquidTransition

This library created for review a way of creation transition between view controllers. 
LiquidTransition provide new API for transition creation: 
- Now you don't need to create separate animation class, percent transition controller and correctly connect all together to perform transition animation. 
- You don't think about how propertly cancel animation.
- The way you perform animation still same.

![Alt text](/../screenshots/gif/web_browser.gif?raw=true "Optional Title")
![Alt text](/../screenshots/gif/photo_browser.gif?raw=true "Optional Title")
![Alt text](/../screenshots/gif/complex_animation.gif?raw=true "Optional Title")

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
        // do not perform here complex operations, cause it calls on app initialization
    }
    
    override func animation(vc1: UIViewController, vc2: UIViewController, container: UIView, duration: Double) {
        vc2.view.alpha = 0
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

