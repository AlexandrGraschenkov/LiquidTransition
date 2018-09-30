//
//  Edge.swift
//  VGen
//
//  Created by Carl Wieland on 4/22/15.
//  Copyright (c) 2015 Carl Wieland. All rights reserved.
//

import Foundation
public class Edge{
    ///pointer to start point
    public var start:Point
    ///pointer to Voronoi place on the left side of edge
    let left:Point
    ///pointer to Voronoi place on the right side of edge
    let right:Point
    ///directional vector, from "start", points to "end", normal of |left, right|
    let direction:Point
    ///pointer to end point
    public var end:Point? = nil
    var neighbour:Edge? = nil
    
    ///Directional coeffitient satisfying equation y = f*x + g (edge lies on this line)
    var f:CGFloat
    ///Directional coeffitient satisfying equation y = f*x + g (edge lies on this line)
    var g:CGFloat

    
    init(start:Point, left:Point, right:Point){
        self.start = start
        self.left = left
        self.right = right
        f = (right.x - left.x) / (left.y - right.y) ;
        g = start.y - f * start.x ;
        direction = Point(x:right.y - left.y, y:-(right.x - left.x));
    }
    
    func reverse() -> Edge {
        let e = Edge(start: end!, left: right, right: left)
        e.end = start
        return e
    }
}

