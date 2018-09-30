//
//  Polygon.swift
//  Voronoi
//
//  Created by Alexander Graschenkov on 29.09.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

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
                    print("WTF")
                    edges.remove(at: i)
                    i -= 1
                }
                i += 1
            }
            let allEdges = edges + getBorderEdges(edges: edges, center: p, bounds: bounds)
            return Polygon(center: p, edges: sort(edges: allEdges))
        }
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
        if l1.bounds().insetBy(dx: -1, dy: -1).contains(p) &&
            l2.bounds().insetBy(dx: -1, dy: -1).contains(p) {
            return p
        }
        return nil
    }
    
    static func clipBounds(edges: [Edge], rect: CGRect) {
        let tl = CGPoint(x: rect.minX, y: rect.minY)
        let tr = CGPoint(x: rect.maxX, y: rect.minY)
        let br = CGPoint(x: rect.maxX, y: rect.maxY)
        let bl = CGPoint(x: rect.minX, y: rect.maxY)
        let rectLines: [Line] = [Line(p1: tl, p2: tr),
                                 Line(p1: tr, p2: br),
                                 Line(p1: br, p2: bl),
                                 Line(p1: bl, p2: tl)]
        var rect = rect.insetBy(dx: -1, dy: -1)
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
    
    static func sort(edges: [Edge]) -> [Edge] {
        var edges = edges
        
        // sort edges in circle
        var sortedEdges: [Edge] = []
        
        while let e = edges.popLast() {
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
    
    func isClokwise() -> Bool {
        let p1 = edges[0].start
        let p2 = edges[1].start
        let p3 = edges[2].start
        let val = (p2.y - p1.y) * (p3.x - p2.x) - (p2.x - p1.x) * (p3.y - p2.y)
            
        if (val == 0) { return false }  // colinear
            
        return (val > 0) // clock or counterclock wise
    }
}
