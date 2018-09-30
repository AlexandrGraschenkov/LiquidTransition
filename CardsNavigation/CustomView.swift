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
    
 
    fileprivate func generateColor(forPoint point: Point) -> UIColor {
        let rand01: ()->(CGFloat) = { return CGFloat(arc4random() % 1000) / 1000.0 }
        let hue : CGFloat = rand01()
        let saturation : CGFloat = rand01() * 0.5 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = rand01() * 0.5 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }

}
