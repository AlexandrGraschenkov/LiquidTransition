//
//  BrokenViewTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 01.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Voronoi

class BrokenViewTransition: TransitionAnimator<TestBrokenAnimationController, UIViewController> {

    init() {
        super.init(from: TestBrokenAnimationController.self, to: UIViewController.self, direction: .dismiss)
        
        duration = 0.7
    }
    
    
    func rand(from: CGFloat = 0, to: CGFloat = 1) -> CGFloat {
        let val = CGFloat(arc4random() % 10000) / 10000.0
        return val * (to - from) + from
    }
    
    func generatePointsForVoroni(point: CGPoint, bounds: CGRect) -> [CGPoint] {
        var points: [CGPoint] = []
        
        let circleCount = 12
        let minStep = 1.0 / CGFloat(circleCount)
        let radius: CGFloat = 20
        for i in [Int](0...circleCount) {
            var angle = CGFloat(i) / CGFloat(circleCount)
            angle += rand(from: -0.4, to: 0.4) * minStep
            angle = .pi * 2 * angle
            let r = radius * rand(from: 0.99, to: 1.01)
            let p = CGPoint(x: point.x + cos(angle) * r,
                            y: point.y + sin(angle) * r)
            points.append(p)
        }
        
        while points.count < 50 {
            let p = CGPoint(x: rand() * bounds.width, y: rand() * bounds.height)
            let dist = sqrt(pow(point.x - p.x, 2) + pow(point.y - p.y, 2))
            if dist < radius * 1.5 { continue }
            points.append(p)
        }
        return points
    }
    
    func buildPolygons(fromPoint point: CGPoint, bounds: CGRect) -> [Polygon] {
        var polygons: [Polygon] = []
        let voronoi = Voronoi()
        while true {
            let points = generatePointsForVoroni(point: point, bounds: bounds)
            let edges = voronoi.getEdges(v: points.map({Point(x: $0.x, y: $0.y)}), w: bounds.size.width, h: bounds.size.height)
            polygons = Polygon.build(edges: edges, bounds: bounds)
            
            var isAllOk = true
            for p in polygons {
                if p.edges.count == 0 {
                    isAllOk = false
                    break
                }
            }
            
            if isAllOk { break }
        }
        
        return polygons
    }
    
    func bringImageToPolygons(img: UIImage, polygons: [Polygon]) -> [UIView] {
        var views: [UIView] = []
        for p in polygons {
            let rect = p.bounds()
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
            guard let ctx = UIGraphicsGetCurrentContext() else {
                continue
            }
            
            ctx.translateBy(x: -rect.minX, y: -rect.minY)
            p.bezierPath().addClip()
            img.draw(at: CGPoint.zero)
            if let clipImg = UIGraphicsGetImageFromCurrentImageContext() {
                let view = UIImageView(image: clipImg)
                view.frame = rect
                views.append(view)
            }
            UIGraphicsEndImageContext()
        }
        return views
    }
    
    func broke(view: UIView, fromPoint point: CGPoint) -> [UIView] {
        let img = view.snapshotImage(scale: 1.0)
        let polygons = self.buildPolygons(fromPoint: point, bounds: view.bounds)
        let views = self.bringImageToPolygons(img: img, polygons: polygons)
        return views
    }
    
    
    override func animation(vc1: TestBrokenAnimationController, vc2: UIViewController, container: UIView, duration: Double) {
        let point = vc1.dismissFromPoint
        let brokenPieces = broke(view: vc1.view, fromPoint: point)
        for view in brokenPieces {
            container.addSubview(view)
        }
        
        vc1.view.isHidden = true
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            for view in brokenPieces {
                let offset = (view.center - point).norm() * vc1.view.bounds.height
                view.center = offset + view.center
//                view.ka
            }
        }) { (_) in
            vc1.view.isHidden = false
        }
    }
}

fileprivate extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    static func * (lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs * rhs.x, y: lhs * rhs.y)
    }
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    func norm() -> CGPoint {
        return self / distance()
    }
}
