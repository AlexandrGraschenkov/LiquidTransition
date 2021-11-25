//
//  Polygon.swift
//  Voronoi
//
//  Created by Alexander Graschenkov on 29.09.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit


fileprivate struct Line {
    let p1: CGPoint
    let p2: CGPoint
    func bounds() -> CGRect {
        let minX = min(p1.x, p2.x)
        let minY = min(p1.y, p2.y)
        let maxX = max(p1.x, p2.x)
        let maxY = max(p1.y, p2.y)
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

public class Polygon: NSObject {

    public let edges: [Edge]
    public let center: Point
    
    public init(center: Point, edges: [Edge]) {
        self.edges = edges
        self.center = center
        super.init()
    }
    
    public static func build(edges: [Edge], bounds: CGRect) -> [Polygon] {
        var map: [Point: [Edge]] = [:]
        for e in edges {
            if e.end == nil { continue }
            if e.start == e.end! { continue }
            for p in [e.left, e.right] {
                if map[p] == nil {
                    map[p] = []
                }
                map[p]?.append(e)
            }
        }
        
        return map.map { (p: Point, edges: [Edge]) -> Polygon in
            var lines: [Line] = []
            for e in edges {
                lines.append(Line(p1: e.start.cgPoint, p2: e.end!.cgPoint))
            }
            clipBounds(edges: edges, rect: bounds)
            let rect = bounds.insetBy(dx: -1, dy: -1)
            var i = 0
            var edges = edges
            while i < edges.count {
                let e = edges[i]
                if !rect.contains(e.start.cgPoint) && !rect.contains(e.end!.cgPoint) {
                    edges.remove(at: i)
                    i -= 1
                }
                i += 1
            }
            let allEdges = edges + getBorderEdges(edges: edges, center: p, bounds: bounds)
            return Polygon(center: p, edges: sort(edges: allEdges))
        }
    }
    
    public func bounds() -> CGRect {
        if edges.count == 0 { return CGRect.zero }
        var minP = edges[0].start.cgPoint
        var maxP = edges[0].start.cgPoint
        for e in edges {
            for p in [e.start.cgPoint, e.end!.cgPoint] {
                minP.x = min(p.x, minP.x)
                minP.y = min(p.y, minP.y)
                maxP.x = max(p.x, maxP.x)
                maxP.y = max(p.y, maxP.y)
            }
        }
        return CGRect(x: minP.x,
                      y: minP.y,
                      width: maxP.x - minP.x,
                      height: maxP.y - minP.y)
    }
    
    public func bezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        if edges.count == 0 { return path }
        
        path.move(to: edges[0].start.cgPoint)
        for e in edges {
            path.addLine(to: e.end!.cgPoint)
        }
        path.close()
        return path
    }
    
    static func isClose(_ a: CGFloat, _ b: CGFloat) -> Bool {
        return abs(a-b) < 1e-5
    }
    
    static func getBorderEdges(edges: [Edge], center: Point, bounds: CGRect) -> [Edge] {
        var onXBorder: [Point] = []
        var onYBorder: [Point] = []
        for e in edges {
            for p in [e.start, e.end!] {
                if isClose(p.x, bounds.minX) || isClose(p.x, bounds.maxX) {
                    onXBorder.append(p)
                }
                if isClose(p.y, bounds.minY) || isClose(p.y, bounds.maxY) {
                    onYBorder.append(p)
                }
            }
        }
        
        if onXBorder.count + onYBorder.count != 2 { return [] }
        
        if onXBorder.count == 2 || onYBorder.count == 2 {
            let points = onXBorder + onYBorder
            let e = Edge(start: points[0], left: center, right: center)
            e.end = points[1]
            return [e]
        }
        
        let cornerPoint = Point(x: onXBorder[0].x, y: onYBorder[0].y)
        let e1 = Edge(start: onXBorder[0], left: center, right: center)
        e1.end = cornerPoint
        let e2 = Edge(start: onYBorder[0], left: center, right: center)
        e2.end = cornerPoint
        return [e1, e2]
    }
    
    static fileprivate func intersection(l1: Line, l2: Line) -> CGPoint? {
        // Store the values for fast access and easy
        // equations-to-code conversion
        let x1 = l1.p1.x, x2 = l1.p2.x, x3 = l2.p1.x, x4 = l2.p2.x;
        let y1 = l1.p1.y, y2 = l1.p2.y, y3 = l2.p1.y, y4 = l2.p2.y;
        
        let d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
        // If d is zero, there is no intersection
        if (d == 0) { return nil }
        
        // Get the x and y
        let pre = (x1*y2 - y1*x2), post = (x3*y4 - y3*x4);
        let x = ( pre * (x3 - x4) - (x1 - x2) * post ) / d;
        let y = ( pre * (y3 - y4) - (y1 - y2) * post ) / d;
        
        let p = CGPoint(x: x, y: y)
        if l1.bounds().insetBy(dx: -0.1, dy: -0.1).contains(p) &&
            l2.bounds().insetBy(dx: -0.1, dy: -0.1).contains(p) {
            return p
        }
        return nil
    }
    
    static fileprivate func clipBounds(edges: [Edge], rect: CGRect) {
        let tl = CGPoint(x: rect.minX, y: rect.minY)
        let tr = CGPoint(x: rect.maxX, y: rect.minY)
        let br = CGPoint(x: rect.maxX, y: rect.maxY)
        let bl = CGPoint(x: rect.minX, y: rect.maxY)
        let rectLines: [Line] = [Line(p1: tl, p2: tr),
                                 Line(p1: tr, p2: br),
                                 Line(p1: br, p2: bl),
                                 Line(p1: bl, p2: tl)]
        let rect = rect.insetBy(dx: -1, dy: -1)
        for e in edges {
            if rect.contains(e.start.cgPoint) && rect.contains(e.end!.cgPoint) {
                continue
            }
            let edgeLine = Line(p1: e.start.cgPoint, p2: e.end!.cgPoint)
            for rLine in rectLines {
                if let p = intersection(l1: rLine, l2: edgeLine) {
                    if rect.contains(e.start.cgPoint) {
                        e.end = Point(x: p.x, y: p.y)
                    } else {
                        e.start = Point(x: p.x, y: p.y)
                    }
                }
            }
        }
    }
    
    static fileprivate func sort(edges: [Edge]) -> [Edge] {
        var edges = edges
        
        // sort edges in circle
        var sortedEdges: [Edge] = []
        
        var testCount = edges.count * 10
        while let e = edges.popLast() {
            testCount -= 1
            if testCount == 0 {
                return []
            }
            if e.end == nil { continue }
            if sortedEdges.count == 0 || sortedEdges.last!.end! == e.start {
                sortedEdges.append(e)
            } else if sortedEdges.last!.end! == e.end! {
                sortedEdges.append(e.reverse())
            } else {
                edges.insert(e, at: 0) // edge wait his time
            }
        }
        return sortedEdges
    }
}
