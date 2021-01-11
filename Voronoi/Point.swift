//
//  Point.swift
//  VGen
//
//  Created by Carl Wieland on 4/22/15.
//  Copyright (c) 2015 Carl Wieland. All rights reserved.
//

import Foundation

public class Point:Equatable,Hashable {
    public let x:CGFloat
    public let y:CGFloat
    
    public init(x:CGFloat, y:CGFloat){
        self.x = x
        self.y = y
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
    
    public var cgPoint:CGPoint{
        return CGPoint(x: x, y: y)
    }
}

public func == (lhs:Point, rhs:Point)->Bool{
    return (lhs.y - rhs.y < 1e-5 && lhs.y - rhs.y > -(1e-5) ) && (lhs.x - rhs.x < 1e-5 && lhs.x - rhs.x > -(1e-5) )
}


extension Point: CustomStringConvertible{
    public var description:String{
        let xStr = String(format: "%.2f", x)
        let yStr = String(format: "%.2f", y)
        return "(\(xStr),\(yStr))"
    }
}
