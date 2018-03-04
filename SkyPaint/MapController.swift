//
//  MapController.swift
//  SkyPaint
//
//  Created by Jason Halcomb on 3/3/18.
//  Copyright © 2018 SkyPaint. All rights reserved.
//

import UIKit
import DJISDK
import VideoPreviewer
import MapKit
import CoreLocation

class MapController: UIViewController, CLLocationManagerDelegate {
   
    @IBOutlet var mapView: MKMapView!
    var locationManager: CLLocationManager?
    var userLocation: CLLocationCoordinate2D?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startUpdateLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.userLocation = kCLLocationCoordinate2DInvalid
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.locationManager?.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startUpdateLocation() {
        if (CLLocationManager.locationServicesEnabled()){
            if (self.locationManager == nil){
                self.locationManager = CLLocationManager()
                self.locationManager?.delegate = self
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager?.distanceFilter = 0.1
                locationManager?.requestAlwaysAuthorization()
                self.locationManager?.startUpdatingLocation()
            }
        }
    }
    
    @IBAction func focusMap(_ sender: Any) {
        if (CLLocationCoordinate2DIsValid(self.userLocation!)){
            var region = MKCoordinateRegion()
            region.center = self.userLocation!
            region.span.latitudeDelta = 0.001
            region.span.longitudeDelta = 0.001
            
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.userLocation = location?.coordinate
    }
}
