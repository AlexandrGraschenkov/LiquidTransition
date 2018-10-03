//
//  CustomView.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 22.09.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Voronoi

class CustomView: UIView {

    let voronoi = Voronoi()
    
    
    var points: [CGPoint] = [] {
        didSet {
            pointsUpdated()
        }
    }
    
    func pointsUpdated() {
        
        edges = voronoi.getEdges(v: points.map({Point(x: $0.x, y: $0.y)}), w: bounds.size.width, h: bounds.size.height)
        polygons = Polygon.build(edges: edges, bounds: bounds)
        self.setNeedsDisplay()
    }
    
    fileprivate var edges: [Edge] = []
    fileprivate var polygons: [Polygon] = []
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        
        for e in edges {
            guard let end = e.end else { continue }
            ctx.move(to: e.start.cgPoint)
            ctx.addLine(to: end.cgPoint)
        }
        ctx.setLineWidth(9.0)
        ctx.setStrokeColor(UIColor.red.cgColor)
        ctx.strokePath()
        
        
        ctx.setLineWidth(3.0)
        ctx.setStrokeColor(UIColor.green.cgColor)
        for p in polygons {
            let color = generateColor(forPoint: p.center)
            ctx.setFillColor(color.cgColor)
            guard let firstPoint = p.edges.first?.start.cgPoint else { continue }
            ctx.move(to: firstPoint)
            for e in p.edges {
                ctx.addLine(to: e.end!.cgPoint)
            }
            ctx.closePath()
//            ctx.fill
//            ctx.fillPath()
            
            ctx.drawPath(using: .eoFillStroke)
//            break
        }
    }
    
    func rand() -> CGFloat {
        return CGFloat(arc4random() % 1000) / 1000.0
    }
    
    func geneareBorenWindow(fromPoint point: CGPoint) {
        var pointsToAdd: [CGPoint] = []
        
        let circleCount = 12
        let minStep = 1.0 / CGFloat(circleCount)
        let radius: CGFloat = 20
        for i in [Int](0...circleCount) {
            var angle = CGFloat(i) / CGFloat(circleCount)
            angle += (rand() - 0.5) * 0.4 * minStep
            angle = .pi * 2 * angle
            let r: CGFloat = radius * ((rand() - 0.5) * 0.01 + 1)
            let p = CGPoint(x: point.x + cos(angle) * r,
                            y: point.y + sin(angle) * r)
            pointsToAdd.append(p)
        }
        
        while pointsToAdd.count < 50 {
            let p = CGPoint(x: rand() * bounds.width, y: rand() * bounds.height)
            let dist = sqrt(pow(point.x - p.x, 2) + pow(point.y - p.y, 2))
            if dist < radius * 1.5 { continue }
            pointsToAdd.append(p)
        }
        
        points = pointsToAdd
    }
    
 
    fileprivate func generateColor(forPoint point: Point) -> UIColor {
        let hue : CGFloat = rand()
        let saturation : CGFloat = rand() * 0.5 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = rand() * 0.5 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }

}
