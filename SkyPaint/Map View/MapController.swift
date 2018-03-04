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

class MapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
   
    
    @IBOutlet weak var LatitudeSlider: UISlider!
    @IBOutlet weak var LatitudeLabel: UILabel!
    @IBOutlet weak var LongitudeSlider: UISlider!
    @IBOutlet weak var LongitudeLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    
    var locationManager: CLLocationManager?
    var userLocation: CLLocationCoordinate2D?
    var placingCenter = true
    var center: CLLocationCoordinate2D?
    var regionPins: [MKPointAnnotation]
    var latOffset = CLLocationDegrees(0.001)
    var lonOffset = CLLocationDegrees(0.001)
    
    required init?(coder aDecoder: NSCoder) {
        self.regionPins = [MKPointAnnotation]()
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startUpdateLocation()
        messageLabel.text = "Set Center..."
        confirmButton.setTitle("Confirm Center", for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.userLocation = kCLLocationCoordinate2DInvalid
        
        let touchEvent = UITapGestureRecognizer(target: self, action: #selector(MapController.mapTap(_:)))
        mapView.addGestureRecognizer(touchEvent)
        
        mapView.delegate = self
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
            region.span.latitudeDelta = 0.004
            region.span.longitudeDelta = 0.004
            
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.userLocation = location?.coordinate
    }
    
    @objc func mapTap(_ recognizer: UIGestureRecognizer) {
        let touchedAt = recognizer.location(in: self.mapView)
        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView)
        
        if (placingCenter) {
            self.clearMap()
            
            let newPin = MKPointAnnotation()
            newPin.coordinate = touchedAtCoordinate
            mapView.addAnnotation(newPin)
        }
    }
    
    func clearMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    @IBAction func confirmPoints(_ sender: Any) {
        if (placingCenter){
            self.center = mapView.annotations[0].coordinate
            NSLog("ORIGIN (\(center?.latitude ?? 0), \(center?.longitude ?? 0))")
            confirmButton.setTitle("Confirm Scale", for: .normal)
            messageLabel.text = "Set scale using sliders..."
            
            LongitudeSlider.isHidden = false;
            LatitudeSlider.isHidden = false;
            LongitudeLabel.isHidden = false;
            LatitudeLabel.isHidden = false;
            
            regionPins.append(MKPointAnnotation())
            regionPins.append(MKPointAnnotation())
            regionPins.append(MKPointAnnotation())
            regionPins.append(MKPointAnnotation())
            
            self.positionRegionPoints()
            
            placingCenter = false
        }
        else {
            let latitudeScale = abs(regionPins[1].coordinate.latitude-regionPins[2].coordinate.latitude)/500
            let longitudeScale = abs(regionPins[0].coordinate.longitude-regionPins[1].coordinate.longitude)/500
            
            performSegue(withIdentifier: "mapToConfirmSegue", sender: nil)
        }
    }
    
    func positionRegionPoints() {
        regionPins[0].coordinate = CLLocationCoordinate2D(latitude: center!.latitude+latOffset, longitude: center!.longitude-lonOffset)
        regionPins[1].coordinate = CLLocationCoordinate2D(latitude: center!.latitude+latOffset, longitude: center!.longitude+lonOffset)
        regionPins[2].coordinate = CLLocationCoordinate2D(latitude: center!.latitude-latOffset, longitude: center!.longitude+lonOffset)
        regionPins[3].coordinate = CLLocationCoordinate2D(latitude: center!.latitude-latOffset, longitude: center!.longitude-lonOffset)
        
        clearMap()
        
        mapView.addAnnotation(regionPins[0])
        mapView.addAnnotation(regionPins[1])
        mapView.addAnnotation(regionPins[2])
        mapView.addAnnotation(regionPins[3])
        
        let region = MKPolygon(coordinates: [regionPins[0].coordinate, regionPins[1].coordinate, regionPins[2].coordinate, regionPins[3].coordinate], count: 4)
        mapView.add(region)
        
        let pin0 = CLLocation(latitude: regionPins[0].coordinate.latitude, longitude: regionPins[0].coordinate.longitude)
        let pin1 = CLLocation(latitude: regionPins[1].coordinate.latitude, longitude: regionPins[1].coordinate.longitude)
        let pin2 = CLLocation(latitude: regionPins[2].coordinate.latitude, longitude: regionPins[2].coordinate.longitude)
        
        var distance = pin1.distance(from: pin2)
        LatitudeLabel.text = "\(distance.rounded())m"
        distance = pin0.distance(from: pin1)
        LongitudeLabel.text = "\(distance.rounded())m"
    }
    
    @IBAction func latitudeSliderChanged(_ sender: Any) {
        latOffset = CLLocationDegrees(0.001 * LatitudeSlider.value)
        positionRegionPoints()
    }
    @IBAction func longitudeSliderChanged(_ sender: Any) {
        lonOffset = CLLocationDegrees(0.001 * LongitudeSlider.value)
        positionRegionPoints()
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 2
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
}
