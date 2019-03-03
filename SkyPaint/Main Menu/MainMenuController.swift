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
        let alert = UIAlertController(title: "Disclaimer:", message: "This app is in beta. In order to use with your DJI aircraft, please switch your controller to \"P-Mode\". While using this app, maintain ability to immediately take control of your aircraft by switching to a different mode. Skypaint and it's developers are not responsible for any damages to persons or property as a result of using this app. Please fly responsibly and within all federal regulations.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        let acceptBtn = UIAlertAction(title:"Accept", style: .default, handler:  {(_ action: UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "mainMenuToFlySegue", sender: nil)
        })
        alert.addAction(acceptBtn)
        self.present(alert, animated: true)
    }
    @IBAction func userTappedEdit(_ sender: Any) {
        let alert = UIAlertController(title: "Disclaimer:", message: "This app is in beta. In order to use with your DJI aircraft, please switch your controller to \"P-Mode\". While using this app, maintain ability to immediately take control of your aircraft by switching to a different mode. Skypaint and it's developers are not responsible for any damages to persons or property as a result of using this app. Please fly responsibly and within all federal regulations.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        let acceptBtn = UIAlertAction(title:"Accept", style: .default, handler:  {(_ action: UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "mainMenuToCreateSegue", sender: nil)
        })
        alert.addAction(acceptBtn)
        self.present(alert, animated: true)
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
