//
//  Event.swift
//  VGen
//
//  Created by Carl Wieland on 4/22/15.
//  Copyright (c) 2015 Carl Wieland. All rights reserved.
//

import Foundation
public class Event:Comparable,Hashable{
    ///the point at which current event occurs (top circle point for circle event, focus point for place event)
    let point:Point
    
    //whether it is a place event or not
    let pe:Bool
    ///If pe is true, it is an arch above which the event occurs
    var arch:Parabola? = nil
    
    init(p:Point, pev:Bool){
        point = p;
        pe = pev
    }
    
    public var hashValue: Int {
        var hash = point.hashValue ^ pe.hashValue
        if(arch != nil){
            hash ^ 13
        }
        return hash
    }
}

public func <=(lhs: Event, rhs: Event) -> Bool{
    return lhs.point.y <= rhs.point.y
}

public func >=(lhs: Event, rhs: Event) -> Bool{
    return lhs.point.y >= rhs.point.y
}

public func <(lhs: Event, rhs: Event) -> Bool{
    if(lhs.point.y - rhs.point.y < 1e-5 && lhs.point.y - rhs.point.y > -(1e-5)){
        return lhs.point.x < rhs.point.x
    }
    return lhs.point.y < rhs.point.y
}

public func ==(lhs: Event, rhs: Event) -> Bool{
    return lhs.point == rhs.point && lhs.pe == rhs.pe && lhs.arch === rhs.arch
}
