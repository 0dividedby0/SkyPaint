//
//  ViewController.swift
//  SkyPaint
//
//  Created by Jason Halcomb on 3/1/18.
//  Copyright © 2018 SkyPaint. All rights reserved.
//

import UIKit
import DJISDK
import VideoPreviewer

class FlightController: UIViewController, DJIVideoFeedListener, DJICameraDelegate {
    
    @IBOutlet var liveView: UIView!
    
    @IBAction func returnToMain(_ sender: Any) {
        performSegue(withIdentifier: "flyToMainMenuSegue", sender: nil)
    }
    @IBAction func loadPath(_ sender: Any) {
        performSegue(withIdentifier: "flyToPathSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (DJISDKManager.product() == nil) {
            let alert = UIAlertController(title: "No Connection", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else {
            let camera = (DJISDKManager.product() as! DJIAircraft).camera
            camera!.delegate = self
            
            self.setupVideoPreviewer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let camera = (DJISDKManager.product() as! DJIAircraft).camera
        if (camera != nil && camera?.delegate as! FlightController == self){
            camera!.delegate = nil;
        }
        self.resetVideoPreview();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupVideoPreviewer() {
        VideoPreviewer.instance().setView(self.liveView)
        VideoPreviewer.instance().adjustViewSize()
        
        DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        
        VideoPreviewer.instance().start()
    }
    
    func resetVideoPreview() {
        VideoPreviewer.instance().unSetView()
        DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
    }
    
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData rawData: Data) {
        let videoData = rawData as NSData
        let videoBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.length)
        
        videoData.getBytes(videoBuffer, length: videoData.length)
        VideoPreviewer.instance().push(videoBuffer, length: Int32(videoData.length))
    }
    
    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        
    }
    
}

