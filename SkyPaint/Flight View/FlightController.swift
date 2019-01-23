//
//  ViewController.swift
//  SkyPaint
//
//  Created by Jason Halcomb on 3/1/18.
//  Copyright © 2018 SkyPaint. All rights reserved.
//

import UIKit
import DJISDK
import DJIUXSDK

class FlightController: DUXDefaultLayoutViewController {
    
    @IBAction func returnToMain(_ sender: Any) {
        performSegue(withIdentifier: "flyToMainMenuSegue", sender: nil)
    }
    @IBAction func loadPath(_ sender: Any) {
        performSegue(withIdentifier: "flyToPathSegue", sender: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        (self.contentViewController as! DUXFPVViewController).fpvView?.showCameraDisplayName = false
    }
    
}
