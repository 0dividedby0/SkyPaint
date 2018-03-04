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
    
    var points:[(Float, Float, Float)] = []

    var plane: String?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addStartPoint() -> Void
    {
        var newPoint:CGPoint
        var coor1:CGFloat
        var coor2:CGFloat
        
        if(plane == "XZ")
        {
            coor1 = CGFloat(points[0].0) + 250
            coor2 = CGFloat(points[0].2) * -1 + 400
        }
        else if(plane == "YZ")
        {
            coor1 = CGFloat(points[0].1) + 250
            coor2 = CGFloat(points[0].2) * -1 + 400
        }
        else
        {
            coor1 = CGFloat(points[0].0) + 250
            coor2 = CGFloat(points[0].1) * -1 + 250
        }
        
        newPoint = CGPoint(x: coor1, y: coor2) //initial point
        path.move(to: newPoint)
    }
    
    func addPoints() -> Void
    {
        var newPoint:CGPoint
        
        for i in 0..<points.count{

            var coor1:CGFloat
            var coor2:CGFloat
            
            if(plane == "XZ")
            {
                coor1 = CGFloat(points[i].0) + 250
                coor2 = CGFloat(points[i].2) * -1 + 400
            }
            else if(plane == "YZ")
            {
                coor1 = CGFloat(points[i].1) + 250
                coor2 = CGFloat(points[i].2) * -1 + 400
            }
            else
            {
                coor1 = CGFloat(points[i].0) + 250
                coor2 = CGFloat(points[i].1) * -1 + 250
            }
            
            newPoint = CGPoint(x: coor1, y: coor2) //initial point
            path.addLine(to: newPoint)
        }
    }
    
    func createPath() {
        // Initialize the path.
        path = UIBezierPath()
        
        if(points.count > 0)
        {
            addStartPoint()
            addPoints()
        }
    }
    
    
    override public func draw(_ rect: CGRect) {
        self.createPath()
        
        UIColor.white.setStroke()
        
        path.stroke()
    }

    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
