//
//  pathDisplayView.swift
//  SkyPaint
//
//  Created by Addisalem Kebede on 3/3/18.
//  Copyright © 2018 SkyPaint. All rights reserved.
//

import UIKit

public class pathDisplayView: UIView {

    var path: UIBezierPath!
    let dot = UIImage(named: "Circle")!
    var points:[(Float, Float, Float)] = []
    var plane: String?
    var scale:Float!
    var zScale:Float!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*******************************************************************************
     // Function: addStartPoint
     // Called when: createPath is called
     // Usage: to add the key start point of a path
     ********************************************************************************/
    func addStartPoint() -> Void
    {
        var newPoint:CGPoint
        var coor1:CGFloat
        var coor2:CGFloat
        
        if(plane == "XZ")
        {
            coor1 = (CGFloat(points[0].0)+250)/CGFloat(scale)
            coor2 = CGFloat(points[0].2)/CGFloat(zScale) * -1 + CGFloat(400/zScale)
        }
        else if(plane == "YZ")
        {
            coor1 = CGFloat(points[0].1)/CGFloat(scale) + CGFloat(250/scale)
            coor2 = CGFloat(points[0].2)/CGFloat(zScale) * -1 + CGFloat(400/zScale)
        }
        else
        {
            coor1 = (CGFloat(points[0].0) + 250)/CGFloat(scale)
            coor2 = CGFloat(points[0].1)/CGFloat(scale) * -1 + CGFloat(250/scale)
        }
        newPoint = CGPoint(x: coor1, y: coor2) //initial point
        path.move(to: newPoint)
        
    }
    
    /*******************************************************************************
     // Function: addPoints
     // Called when: createPath is called
     // Usage: to add any addtional points apart from start point to pDV
     ********************************************************************************/
    func addPoints() -> Void
    {
        var newPoint:CGPoint
        
        for i in 0..<points.count{

            var coor1:CGFloat
            var coor2:CGFloat
            
            if(plane == "XZ")
            {
                coor1 = (CGFloat(points[i].0)+250)/CGFloat(scale)
                coor2 = CGFloat(points[i].2)/CGFloat(zScale) * -1 + CGFloat(400/zScale)
            }
            else if(plane == "YZ")
            {
                coor1 = CGFloat(points[i].1)/CGFloat(scale) + CGFloat(250/scale)
                coor2 = CGFloat(points[i].2)/CGFloat(zScale) * -1 + CGFloat(400/zScale)
            }
            else
            {
                coor1 = (CGFloat(points[i].0) + 250)/CGFloat(scale)
                coor2 = CGFloat(points[i].1)/CGFloat(scale) * -1 + CGFloat(250/scale)
            }

            
            newPoint = CGPoint(x: coor1, y: coor2) ///initial point
            path.addLine(to: newPoint)
            
            let area = CGRect(x: ((newPoint.x - 10)), y: (newPoint.y - 10), width: 20, height: 20)
            dot.draw(in: area)
        }
    }
    
    /*******************************************************************************
     // Function: createPath
     // Called when: ???????????????
     // Usage: ???????????????
     ********************************************************************************/
    func createPath() {        /// Initialize the path.
        path = UIBezierPath()
        
        if(points.count > 0)
        {
            addStartPoint()
            addPoints()
        }
    }
    
    
    /*******************************************************************************
     // Function: draw
     // Called when: redrawing pDV
     // Usage: to draw the new path on pDV
     ********************************************************************************/
    override public func draw(_ rect: CGRect) { /// draws path with white color stroke
        self.createPath()
        UIColor.white.setStroke()
        path.stroke()
    }
}
