//
//  Timing.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 10.09.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

public class Timing {
    
    public static let `default`: Timing = Timing(functionName: .default)
    public static let linear: Timing = Timing(closure: {$0})
    public static let easeIn: Timing = Timing(functionName: .easeIn)
    public static let easeOut: Timing = Timing(functionName: .easeOut)
    public static let easeInOut: Timing = Timing(functionName: .easeInEaseOut)
    
    public convenience init(functionName: CAMediaTimingFunctionName) {
        self.init(function: CAMediaTimingFunction(name: functionName))
    }
    
    public convenience init(function: CAMediaTimingFunction) {
        var p1: [Float] = [0.0,0.0]
        var p2: [Float] = [0.0,0.0]
        
        function.getControlPoint(at: 1, values: &p1)
        function.getControlPoint(at: 2, values: &p2)
        
        self.init(cp1: CGPoint(x: CGFloat(p1[0]), y: CGFloat(p1[1])),
                  cp2: CGPoint(x: CGFloat(p2[0]), y: CGFloat(p2[1])))
    }
    
    public init(cp1: CGPoint, cp2: CGPoint) {
        p1 = cp1
        p2 = cp2
        updateCoefficients()
    }
    
    public init(closure: @escaping (CGFloat)->(CGFloat)) {
        customClosure = closure
    }
    
    public func getValue(x: CGFloat, duration: CGFloat = 1.0) -> CGFloat {
        if let closure = customClosure {
            return closure(x)
        }
        
        let eps = 1.0 / (200.0 * duration)
        let t = solve(x: x, epsilon: eps)
        return getSampleCurveY(t: t)
    }
    
    // MARK: - Private
    
    fileprivate var p1: CGPoint = .zero
    fileprivate var p2: CGPoint = CGPoint(x: 1, y: 1)
    fileprivate var cx: CGFloat = 0
    fileprivate var bx: CGFloat = 0
    fileprivate var ax: CGFloat = 0
    fileprivate var cy: CGFloat = 0
    fileprivate var by: CGFloat = 0
    fileprivate var ay: CGFloat = 0
    fileprivate var customClosure: ((CGFloat)->(CGFloat))? = nil
    
    fileprivate func updateCoefficients() {
        cx = 3.0 * p1.x
        bx = 3.0 * (p2.x - p1.x) - cx
        ax = 1.0 - cx - bx
        
        cy = 3.0 * p1.y
        by = 3.0 * (p2.y - p1.y) - cy
        ay = 1.0 - cy - by
    }
    
    fileprivate func getSampleCurveX(t: CGFloat) -> CGFloat {
        return ((ax * t + bx) * t + cx) * t
    }
    
    fileprivate func getSampleCurveY(t: CGFloat) -> CGFloat {
        return ((ay * t + by) * t + cy) * t
    }
    
    fileprivate func getSampleCurveDerivativeX(t: CGFloat) -> CGFloat {
        return (3.0 * ax * t + 2.0 * bx) * t + cx
    }
    
    
    fileprivate func solve(x: CGFloat, epsilon: CGFloat) -> CGFloat {
        var t0: CGFloat = 0
        var t1: CGFloat = 0
        var t2: CGFloat = x
        var x2: CGFloat = 0
        var d2: CGFloat = 0
        
        // First try a few iterations of Newton's method -- normally very fast.
        for _ in 0..<8 {
            x2 = getSampleCurveX(t: t2) - x
            if (abs(x2) < epsilon) {
                return t2
            }
            
            d2 = getSampleCurveDerivativeX(t: t2)
            if (abs(d2) < 1e-6) {
                break
            }
            t2 = t2 - x2 / d2
        }
        
        // Fall back to the bisection method for reliability.
        t0 = 0.0
        t1 = 1.0
        t2 = x
        
        if (t2 < t0) {
            return t0
        }
        if (t2 > t1) {
            return t1
        }
        
        while (t0 < t1) {
            x2 = getSampleCurveX(t: t2)
            if (abs(x2 - x) < epsilon) {
                return t2
            }
            if (x > x2) {
                t0 = t2
            } else {
                t1 = t2
            }
            t2 = (t1 + t0) * 0.5
        }
        
        // Failure.
        return t2
    }
}

// additional curves
extension Timing {
    // http://easings.net/
    public static let easeInSine = Timing(cp1: CGPoint(x: 0.47, y: 0), cp2: CGPoint(x: 0.745, y: 0.715))
    public static let easeOutSine = Timing(cp1: CGPoint(x: 0.39, y: 0.575), cp2: CGPoint(x: 0.565, y: 1))
    public static let easeInOutSine = Timing(cp1: CGPoint(x: 0.445, y: 0.05), cp2: CGPoint(x: 0.55, y: 0.95))
    
    public static let easeInQuad = Timing(cp1: CGPoint(x: 0.55, y: 0.085), cp2: CGPoint(x: 0.68, y: 0.53))
    public static let easeOutQuad = Timing(cp1: CGPoint(x: 0.25, y: 0.46), cp2: CGPoint(x: 0.45, y: 0.94))
    public static let easeInOutQuad = Timing(cp1: CGPoint(x: 0.455, y: 0.03), cp2: CGPoint(x: 0.515, y: 0.955))
    
    public static let easeInCubic = Timing(cp1: CGPoint(x: 0.55, y: 0.055), cp2: CGPoint(x: 0.675, y: 0.19))
    public static let easeOutCubic = Timing(cp1: CGPoint(x: 0.215, y: 0.61), cp2: CGPoint(x: 0.355, y: 1))
    public static let easeInOutCubic = Timing(cp1: CGPoint(x: 0.645, y: 0.045), cp2: CGPoint(x: 0.355, y: 1))
    
    public static let easeInQuart = Timing(cp1: CGPoint(x: 0.895, y: 0.03), cp2: CGPoint(x: 0.685, y: 0.22))
    public static let easeOutQuart = Timing(cp1: CGPoint(x: 0.165, y: 0.84), cp2: CGPoint(x: 0.44, y: 1))
    public static let easeInOutQuart = Timing(cp1: CGPoint(x: 0.77, y: 0), cp2: CGPoint(x: 0.175, y: 1))
    
    public static let easeInQuint = Timing(cp1: CGPoint(x: 0.755, y: 0.05), cp2: CGPoint(x: 0.855, y: 0.06))
    public static let easeOutQuint = Timing(cp1: CGPoint(x: 0.23, y: 1), cp2: CGPoint(x: 0.32, y: 1))
    public static let easeInOutQuint = Timing(cp1: CGPoint(x: 0.86, y: 0), cp2: CGPoint(x: 0.07, y: 1))
    
    public static let easeInExpo = Timing(cp1: CGPoint(x: 0.95, y: 0.05), cp2: CGPoint(x: 0.795, y: 0.035))
    public static let easeOutExpo = Timing(cp1: CGPoint(x: 0.19, y: 1), cp2: CGPoint(x: 0.22, y: 1))
    public static let easeInOutExpo = Timing(cp1: CGPoint(x: 1, y:0), cp2: CGPoint(x: 0, y: 1))
    
    public static let easeInCirc = Timing(cp1: CGPoint(x: 0.6, y: 0.04), cp2: CGPoint(x: 0.98, y: 0.335))
    public static let easeOutCirc = Timing(cp1: CGPoint(x: 0.075, y: 0.82), cp2: CGPoint(x: 0.165, y: 1))
    public static let easeInOutCirc = Timing(cp1: CGPoint(x: 0.785, y: 0.135), cp2: CGPoint(x: 0.15, y: 0.86))
    
    public static let easeInBack = Timing(cp1: CGPoint(x: 0.6, y: -0.28), cp2: CGPoint(x: 0.735, y: 0.045))
    public static let easeOutBack = Timing(cp1: CGPoint(x: 0.175, y: 0.885), cp2: CGPoint(x: 0.32, y: 1.275))
    public static let easeInOutBack = Timing(cp1: CGPoint(x: 0.68, y: -0.55), cp2: CGPoint(x: 0.265, y: 1.55))
}

// additional closure curves
extension Timing {
    
    public static let easeOutBounce = Timing(closure: easeOutBounceFunc)
    public static let easeInBounce = Timing { (t) -> (CGFloat) in
        return  1.0 - easeOutBounceFunc(t: 1.0 - t)
    }
    
    
    fileprivate static func easeOutBounceFunc(t: CGFloat) -> CGFloat {
        if (t < 4.0 / 11.0) {
            return pow(11.0 / 4.0, 2.0) * pow(t, 2.0)
        }
        
        if (t < 8.0 / 11.0) {
            return 3.0 / 4.0 + pow(11.0 / 4.0, 2) * pow(t - 6.0 / 11.0, 2);
        }
        
        if (t < 10.0 / 11.0) {
            return 15.0 / 16.0 + pow(11.0 / 4.0, 2) * pow(t - 9.0 / 11.0, 2);
        }
        
        return 63.0 / 64.0 + pow(11.0 / 4.0, 2) * pow(t - 21.0 / 22.0, 2);
    }
}
