//
//  BezierHelpers.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 24.05.2021.
//  Copyright © 2021 Alex Development. All rights reserved.
//

import UIKit

struct Corners {
    internal init(tl: CGFloat = 0, tr: CGFloat = 0, bl: CGFloat = 0, br: CGFloat = 0) {
        self.tl = tl
        self.tr = tr
        self.bl = bl
        self.br = br
    }
    
    var tl: CGFloat
    var tr: CGFloat
    var bl: CGFloat
    var br: CGFloat
}

func interpolate(a: CGFloat, b: CGFloat, p: CGFloat) -> CGFloat {
    return (b - a) * p + a
}

struct AnimCornerRect {
    var fromRect: CGRect
    var toRect: CGRect
    var fromCorner: Corners
    var toCorner: Corners
    
    func generateRect(progress: CGFloat) -> CGRect {
        let r = CGRect(x: interpolate(a: fromRect.minX, b: toRect.minX, p: progress),
                       y: interpolate(a: fromRect.minY, b: toRect.minY, p: progress),
                       width: interpolate(a: fromRect.width, b: toRect.width, p: progress),
                       height: interpolate(a: fromRect.height, b: toRect.height, p: progress))
        return r
    }
    
    func generateBezier(progress: CGFloat) -> UIBezierPath {
        var r = generateRect(progress: progress)
        let corners = Corners(tl: interpolate(a: fromCorner.tl, b: toCorner.tl, p: progress),
                              tr: interpolate(a: fromCorner.tr, b: toCorner.tr, p: progress),
                              bl: interpolate(a: fromCorner.bl, b: toCorner.bl, p: progress),
                              br: interpolate(a: fromCorner.br, b: toCorner.br, p: progress))
        r.origin = .zero
        let bezier = UIBezierPath.roundRect(r, radius: corners)
        return bezier
    }
}

extension UIBezierPath {
    static func roundRect(_ rect: CGRect, radius: Corners) -> UIBezierPath {
        let bezier = UIBezierPath()
        let tl = rect.origin
        let tr = CGPoint(x: rect.maxX, y: tl.y)
        let br = CGPoint(x: rect.maxX, y: rect.maxY)
        let bl = CGPoint(x: tl.x, y: rect.maxY)
        
        let pi_2: CGFloat = .pi / 2
        bezier.move(to: CGPoint(x: tl.x, y: tl.y + radius.tl))
        bezier.addArc(withCenter: CGPoint(x: tl.x + radius.tl, y: tl.y + radius.tl),
                      radius: radius.tl,
                      startAngle: .pi,
                      endAngle: .pi*1.5,
                      clockwise: true)
        
        
        bezier.addLine(to: CGPoint(x: tr.x - radius.tr, y: tr.y))
        bezier.addArc(withCenter: CGPoint(x: tr.x - radius.tr, y: tr.y + radius.tr),
                      radius: radius.tr,
                      startAngle: -pi_2,
                      endAngle: 0,
                      clockwise: true)
        
        
        bezier.addLine(to: CGPoint(x: br.x, y: br.y - radius.br))
        bezier.addArc(withCenter: CGPoint(x: br.x - radius.br, y: br.y - radius.br),
                      radius: radius.br,
                      startAngle: 0,
                      endAngle: pi_2,
                      clockwise: true)
        
        
        bezier.addLine(to: CGPoint(x: bl.x + radius.bl, y: bl.y))
        bezier.addArc(withCenter: CGPoint(x: bl.x + radius.bl, y: bl.y - radius.bl),
                      radius: radius.bl,
                      startAngle: pi_2,
                      endAngle: .pi,
                      clockwise: true)
        
        bezier.close()
        
        return bezier
    }
}
