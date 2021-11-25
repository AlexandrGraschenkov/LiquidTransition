//
//  LiquidTransitionTests.swift
//  LiquidTransitionTests
//
//  Created by Alexander Graschenkov on 01.11.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import XCTest
import Liquid

class TVC1: UIViewController {}
class TVC2: UIViewController {}

class Transition: Animator<TVC1, TVC2> {
}

class LiquidTransitionTests: XCTestCase {

    var fromVC: TVC1!
    var toVC: TVC2!
    var transition: Transition!
    var window: UIWindow!
    
    override func setUp() {
        transition = Transition()
        Liquid.shared.addTransition(transition)
        fromVC = TVC1()
        toVC = TVC2()
        
        // init window for test is animation is really works
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = fromVC
        window.makeKeyAndVisible()
        
        fromVC.loadView()
    }

    override func tearDown() {
        Liquid.shared.removeAllTransitions()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBackwardAnimation() {
        
        let callExpectation = expectation(description: "Presented")
        let operationExpectation = expectation(description: "Dismissed")
        
        let testDuration: CGFloat = 0.2
        transition.duration = testDuration
        var appear = true
        var prevVal: CGFloat? = nil
        transition.addCustomAnimation { (val) in
            if prevVal == nil {
                prevVal = val
            }
            if appear {
                XCTAssert(prevVal! <= val)
            } else {
                XCTAssert(prevVal! >= val)
            }
            
            prevVal = val
        }
        
        fromVC.present(toVC, animated: true, completion: {
            appear = false
            prevVal = nil
            callExpectation.fulfill()
            
            self.toVC.dismiss(animated: true, completion: {
                operationExpectation.fulfill()
            })
        })
        
        waitForExpectations(timeout: 0.6) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
}
