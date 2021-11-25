//
//  Parabola.swift
//  VGen
//
//  Created by Carl Wieland on 4/22/15.
//  Copyright (c) 2015 Carl Wieland. All rights reserved.
//

import Foundation


/**
A class that stores information about an item in beachline sequence (see Fortune's algorithm).
It can represent an arch of parabola or an intersection between two archs (which defines an edge).
In my implementation I build a binary tree with them (internal nodes are edges, leaves are archs).
*/
public class Parabola{

    ///Flag whether the node is Leaf or internal node
    public var isLeaf = false;
    
    //pointer to the focus point of parabola (when it is parabola)
    public var site:Point!;
    
    ///pointer to the edge (when it is an edge)
    public var edge:Edge!;
    
    ///Pointer to the event, when the arch disappears (circle event)
    public var event:Event? = nil;
    ///Pointer to the parent node in tree
    public var parent:Parabola?;
    
    /*
    Constructors of the class (empty for edge, with focus parameter for an arch).
    */
    
    init(){}
    
    init(s:Point){
        site = s
        isLeaf = true
    }

    ///Returns the closest left leaf of the tree
    static func getLeft(_ p:Parabola) -> Parabola? {
        return getLeftChild(getLeftParent(p));

    }
    
    ///Returns the closest right leaf of the tree
    static func getRight(_ p:Parabola) -> Parabola? {
        return getRightChild(getRightParent(p));

    }
    
    ///Returns the closest parent which is on the left
    static func getLeftParent(_ p:Parabola) -> Parabola? {
        var par	= p.parent!;
        var pLast = p;
        while(par.left === pLast){
            if let p = par.parent{
                pLast = par
                par = p
            }
            else{
                return nil
            }
        }
        return par;
    }
    
    ///Returns the closest parent which is on the right
    static func getRightParent(_ p:Parabola) -> Parabola? {
        var par	= p.parent!;
        var pLast = p;
        while(par.right === pLast){
            if let p = par.parent{
                pLast = par
                par = p
            }
            else{
                return nil
            }
        }
        return par;
    }
    
    ///Returns the closest leaf which is on the left of current node
    static func getLeftChild(_ pin:Parabola?) -> Parabola? {
        guard let p = pin else { return nil }
        
        var par = p.left!
        while(!par.isLeaf){
            par = par.right
        }
        return par;
    }
    
    ///Returns the closest leaf which is on the right of current node
    static func getRightChild(_ pin:Parabola?) -> Parabola? {
        guard let p = pin else { return nil }
        
        var par = p.right!
        while(!par.isLeaf){
            par = par.left
        }
        return par;
    }
    
    
    /*
    Access to the children (in tree).
    */
    var left:Parabola! {
        didSet{
            left.parent = self
        }
    }
    var right:Parabola! {
        didSet{
            right.parent = self
        }
    }
}
