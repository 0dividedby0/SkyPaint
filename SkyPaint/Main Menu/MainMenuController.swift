//
//  MainMenuController.swift
//  SkyPaint
//
//  Created by Jason Halcomb on 3/3/18.
//  Copyright © 2018 SkyPaint. All rights reserved.
//

import UIKit
import DJISDK

class MainMenuController: UIViewController {
    
    @IBAction func userTappedFly(_ sender: Any) {
        performSegue(withIdentifier: "mainMenuToFlySegue", sender: nil)
    }
    @IBAction func userTappedEdit(_ sender: Any) {
        performSegue(withIdentifier: "mainMenuToCreateSegue", sender: nil)
    }
    
    @IBAction func unwindToMainMenu(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let connectedKey = DJIProductKey(param: DJIParamConnection) else {
            NSLog("Error creating the connectedKey")
            return;
        }
        
        DJISDKManager.keyManager()?.startListeningForChanges(on: connectedKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue : DJIKeyedValue?) in
            if newValue != nil {
                if newValue!.boolValue {
                    // At this point, a product is connected so we can show it.
                    
                    // UI goes on MT.
                    DispatchQueue.main.async {
                        self.productConnected()
                    }
                }
            }
        })
    }
    
    func productConnected() {
        guard let newProduct = DJISDKManager.product() else {
            NSLog("Product is connected but DJISDKManager.product is nil -> something is wrong")
            return;
        }
        
        let connectionString = "Model: \((newProduct.model)!)" + "\n" + "Status: Product Connected"
        
        let alert = UIAlertController(title: "New Connection!", message: connectionString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
}
