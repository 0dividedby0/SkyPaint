//
//  LoadPathWidget.swift
//  SkyPaint
//
//  Created by Jason Halcomb on 2/8/19.
//  Copyright © 2019 SkyPaint. All rights reserved.
//

import UIKit
import DJIUXSDK

class LoadPathWidget: UIView, DUXWidgetProtocol {
    var aspectRatio: CGFloat
    
    var collectionView: DUXWidgetCollectionView?
    
    var interactionExpectationLevel: DUXWidgetInteractionExpectionLevel
    
    var action: DUXWidgetActionBlock?
    
    override init(frame: CGRect) {
        aspectRatio = 1
        interactionExpectationLevel = DUXWidgetInteractionExpectionLevel.full
        super.init(frame: frame)
        
        UIGraphicsBeginImageContext(self.frame.size)
        UIImage(named: "Waypoint Icon")?.draw(in: CGRect(x: 5, y: 0, width: 50, height: 50))
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        aspectRatio = 1
        interactionExpectationLevel = DUXWidgetInteractionExpectionLevel.full
        super.init(coder: aDecoder)
        
        UIGraphicsBeginImageContext(self.frame.size)
        UIImage(named: "Waypoint Icon")?.draw(in: CGRect(x: 5, y: 0, width: 50, height: 50))
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
    
    func dependentKeys() -> [DJIKey] {
        let keys = [DJIKey]()
        return keys
    }
    
    func transform(_ value: DUXSDKModelValue, for key: DJIKey) {
        
    }
}
