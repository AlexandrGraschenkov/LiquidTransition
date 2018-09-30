//
//  Voronoi.swift
//  VGen
//
//  Created by Carl Wieland on 4/22/15.
//  Copyright (c) 2015 Carl Wieland. All rights reserved.
//

import Foundation
public class Voronoi{
    ///Container of Points with which we work
    private var places:[Point]!
    
    ///Container of edges which will be the result
    private var edges = [Edge]()

    ///Width of the diagram
    private var width:CGFloat = 0
    
    ///Height of the diagram
    private var height:CGFloat = 0
    
    ///The root of the tree, that represents a beachline sequence
    private var root:Parabola? = nil

    ///Current "y" position of the line (see Fortune's algorithm)
    private var ly:CGFloat = 0;
    
    ///set of deleted (false) Events (since we can not delete from PriorityQueue
    var	deleted = Set<Event>();
    
    ///list of all new points that were created during the algorithm
    var points = [Point]();
    
    ///Priority queue with events to process
    var queue = PriorityQueue<Event>();
    
    
    
    public init(){
    }
    ///
    ///The only public function for generating a diagram
    ///
    ///:param: v Vertices - places for drawing a diagram
    ///:param: w The width  of the result (top left corner is (0, 0))
    ///:param: h The height of the result
    ///
    ///:returns: A list of edges
    public func getEdges(v:[Point],w:CGFloat, h:CGFloat)->[Edge]{
        places = v;
        width = w;
        height = h;
        root = nil;
        
        points.removeAll(keepingCapacity: true)
        edges.removeAll(keepingCapacity: true)
        if v.count < 3{
            return edges
        }
        
        for point in places
        {
            queue.push(Event(p: point, pev: true));
        }
        
        
        while(!queue.isEmpty)
        {
            let e = queue.pop()!;
            ly = e.point.y
            
            if deleted.contains(e) {
                deleted.remove(e)
                continue
            }

            
            if(e.pe){
                insertParabola(e.point);
   
            }
            else{
                removeParabola(e);
            }
        }
        
        finishEdge(root!);
        for edge in edges{
            if let neigh = edge.neighbour{
                edge.start = neigh.end!
            }
            edge.neighbour = nil

        }
        
        return edges
    }

    ///processing the place event
    private func insertParabola(_ p:Point){
        if let root = self.root{
            
            if(root.isLeaf && root.site.y - p.y < 1){
                let fp = root.site!
                root.isLeaf = false;
                root.left = Parabola(s:fp)
                root.right = Parabola(s:p)
                let s = Point(x:(p.x + fp.x)/2,y: CGFloat(height));
                points.append(s);
                if(p.x > fp.x){
                    root.edge = Edge(start:s,left: fp,right: p);
                }
                else{
                    root.edge = Edge(start:s,left: p, right: fp);
                }
                edges.append(root.edge);
                return;
            }
            
            let par = getParabolaByX(p.x);
            
            if let pEvent = par.event{
                deleted.insert(pEvent);
                par.event = nil;
            }
            
            let start = Point(x:p.x,y: getY(p: par.site, x: p.x));
            points.append(start);
            
            let el = Edge(start:start, left:par.site,right: p);
            let er = Edge(start:start, left: p, right:par.site);
            
            el.neighbour = er;
            edges.append(el);
            

            par.edge = er;
            par.isLeaf = false;
            
            let p0 = Parabola(s:par.site);
            let p1 = Parabola(s:p);
            let p2 = Parabola(s:par.site);
            
            par.right = p2;
            par.left = Parabola();
            par.left.edge = el;
            
            par.left.left = p0;
            par.left.right = p1;
            
            checkCircle(p0);
            checkCircle(p2);
        }
        else{
            root = Parabola(s: p);
        }
    }
    
    ///processing the circle event
    private func removeParabola(_ e:Event){
        let p1 = e.arch!;
        
        let xl = Parabola.getLeftParent(p1)!;
        let xr = Parabola.getRightParent(p1)!;
        
        let p0 = Parabola.getLeftChild(xl)!;
        let p2 = Parabola.getRightChild(xr)!;
        
        if(p0 === p2){
            print("ERROR RIGHT AND LEFT HAVE SAME CHILD!")
        }
        
        if(p0.event != nil){
            deleted.insert(p0.event!);
            p0.event = nil;
        }
        if(p2.event != nil){
            deleted.insert(p2.event!);
            p2.event = nil;
        }
        
        let p = Point(x: e.point.x, y: getY(p: p1.site, x: e.point.x));
        points.append(p);
        
        xl.edge.end = p;
        xr.edge.end = p;
        
        var higher = xl;
        var par = p1;
        while(par !== root)
        {
            par = par.parent!;
            if(par === xl){
                higher = xl;
            }
            if(par === xr) {
                higher = xr;
            }
        }
        higher.edge = Edge(start: p, left: p0.site, right: p2.site);
        edges.append(higher.edge);
        
        let gparent = p1.parent!.parent!;
        if(p1.parent!.left === p1)
        {
            if(gparent.left  === p1.parent){
                gparent.left = p1.parent!.right;

            }
            if(gparent.right === p1.parent) {
                gparent.right = p1.parent!.right;
            }
        }
        else
        {
            if(gparent.left  === p1.parent){
                gparent.left = p1.parent?.left
            }
            if(gparent.right === p1.parent){
                gparent.right = p1.parent?.left
            }
        }

        checkCircle(p0);
        checkCircle(p2);
    }
    
    ///recursively finishes all infinite edges in the tree
    private func finishEdge(_ n:Parabola){
        if(n.isLeaf){
            return;
        }
        let mx:CGFloat;
        if(n.edge.direction.x > 0.0){
            mx = max(width,	n.edge.start.x + 10 );
        }
        else{
            mx = min(0.0, n.edge.start.x - 10);
        }
        
        let end = Point(x:mx,y: mx * n.edge.f + n.edge.g);
        n.edge.end = end;
        points.append(end);
        
        finishEdge(n.left);
        finishEdge(n.right);

    }
    
    ///returns the current x position of an intersection point of left and right parabolas
    private func getXOfEdge(par:Parabola, y:CGFloat) -> CGFloat {
        
        let left = Parabola.getLeftChild(par)!;
        let right = Parabola.getRightChild(par)!;
        
        let p = left.site!
        let r = right.site!
        
        var dp = 2.0 * (p.y - y);
        let a1 = 1.0 / dp;
        let b1 = -2.0 * p.x / dp;
        let c1 = y + dp / 4 + p.x * p.x / dp;
        
        dp = 2.0 * (r.y - y);
        let a2 = 1.0 / dp;
        let b2 = -2.0 * r.x/dp;
        let c2 = ly + dp / 4 + r.x * r.x / dp;
        
        let a = a1 - a2;
        let b = b1 - b2;
        let c = c1 - c2;
        
        let disc = b*b - 4 * a * c;
        let x1 = (-b + sqrt(disc)) / (2*a);
        let x2 = (-b - sqrt(disc)) / (2*a);
        
        let ry:CGFloat
        if(p.y < r.y ){
            ry = max(x1, x2);
        } else {
            ry = min(x1, x2);
        }
        return ry;
    }
    
    ///returns the Parabola that is under this "x" position in the current beachline
    private func getParabolaByX(_ xx:CGFloat)->Parabola{
        var par = root!;
        var x: CGFloat = 0.0;
        
        while(!par.isLeaf) // projdu stromem dokud nenarazÌm na vhodn˝ list
        {
            x = getXOfEdge(par: par, y: ly);
            if(x>xx){
                par = par.left
            }
            else{
                par = par.right;
            }
        }
        return par;
    }
    
    private func getY(p:Point, x:CGFloat)->CGFloat{
        let dp = 2 * (p.y - ly);
        let a1 = 1 / dp;
        let b1 = -2 * p.x / dp;
        let c1 = ly + dp / 4 + p.x * p.x / dp;
        
        return (a1*x*x + b1*x + c1);
    }
    
    ///checks the circle event (disappearing) of this parabola
    private func checkCircle(_ b:Parabola){
        let lp = Parabola.getLeftParent(b);
        let rp = Parabola.getRightParent(b);
        
        if let a  = Parabola.getLeftChild(lp), let c = Parabola.getRightChild(rp) {
            if(a.site === c.site){
                return;
            }
        
            if let s = getEdgeIntersection(a: lp!.edge, b: rp!.edge){
                let dx = a.site.x - s.x;
                let dy = a.site.y - s.y;
                
                let d = sqrt( (dx * dx) + (dy * dy) );
                
                if(s.y - d >= ly){
                    return;
                }
                let e = Event(p: Point(x:s.x, y: s.y - d), pev: false);
                points.append(e.point);
                b.event = e;
                e.arch = b;
                queue.push(e);
            }
        }
    }
    
    private func getEdgeIntersection(a:Edge, b:Edge)->Point?{
        let x = (b.g - a.g) / (a.f - b.f);
        let y = a.f * x + a.g;
        
        if((x - a.start.x)/a.direction.x < 0){ return nil};
        if((y - a.start.y)/a.direction.y < 0){ return nil}
        if((x - b.start.x)/b.direction.x < 0){ return nil}
        if((y - b.start.y)/b.direction.y < 0){ return nil}
        
        let p = Point(x:x,y: y);
        points.append(p);
        return p;
        
        
    }
    
    
}
