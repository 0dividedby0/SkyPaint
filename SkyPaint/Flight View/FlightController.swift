//
//  ViewController.swift
//  SkyPaint
//
//  Created by Jason Halcomb on 3/1/18.
//  Copyright © 2018 SkyPaint. All rights reserved.
//

import UIKit
import DJIUXSDK

class FlightController: DUXDefaultLayoutViewController {
    
    @IBAction func returnToMain(_ sender: Any) {
        performSegue(withIdentifier: "flyToMainMenuSegue", sender: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (self.contentViewController as! DUXFPVViewController).fpvView?.showCameraDisplayName = false
        let widget = LoadPathWidget(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.leadingViewController!.addWidget(widget)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.moveToSelect (_:)))
        widget.addGestureRecognizer(gesture)
    }
    
    @objc func moveToSelect(_ sender:UITapGestureRecognizer){
        performSegue(withIdentifier: "flyToPathSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "flyToPathSegue" {
            let destinationController = segue.destination as! ConfirmationViewController
            destinationController.previousViewIsFlight = true
        }
    }
}
