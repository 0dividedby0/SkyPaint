//
//  MapController.swift
//  SkyPaint
//
//  Created by Jason Halcomb on 3/3/18.
//  Copyright © 2018 SkyPaint. All rights reserved.
//

import UIKit
import DJISDK
import MapKit
import CoreLocation

class MapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
   
    
    @IBOutlet weak var LatitudeSlider: UISlider!
    @IBOutlet weak var LatitudeLabel: UILabel!
    @IBOutlet weak var LongitudeSlider: UISlider!
    @IBOutlet weak var LongitudeLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var segmentedControlMapSelector: UISegmentedControl!
    
    //Map Variables
    var locationManager: CLLocationManager?
    var userLocation: CLLocationCoordinate2D?
    var placingCenter = true
    var readyToStart = false
    var regionPins: [MKPointAnnotation]
    var latOffset = CLLocationDegrees(0.001)
    var lonOffset = CLLocationDegrees(0.001)
    
    //DJI Variables
    var center: CLLocationCoordinate2D?
    var latitudeScale: Double = 1
    var longitudeScale: Double = 1
    let mutablemission:DJIMutableWaypointMission = DJIMutableWaypointMission()
    var path: [Float] = []
    var distanceInMeters: Double?
    var pathNames:[String]?
    var waypoints: [DJIWaypoint] = []
    let missionOperator = DJISDKManager.missionControl()?.waypointMissionOperator()
    var mission: DJIWaypointMission = DJIWaypointMission()
    
    //MARK: - UIViewController Methods
    
    required init?(coder aDecoder: NSCoder) {
        self.regionPins = [MKPointAnnotation]()
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startUpdateLocation()
        confirmButton.setTitle("Confirm Center", for: .normal)
        mapView.mapType = .standard // initializes map in standard
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.userLocation = kCLLocationCoordinate2DInvalid
        
        let touchEvent = UITapGestureRecognizer(target: self, action: #selector(MapController.mapTap(_:)))
        mapView.addGestureRecognizer(touchEvent)
        
        mapView.delegate = self
        
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //check for location services
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate{
            let viewRegion = MKCoordinateRegion.init(center: userLocation, latitudinalMeters: 450, longitudinalMeters: 450)
            mapView.setRegion(viewRegion, animated: false)
            }
        self.locationManager = locationManager
        
        DispatchQueue.main.async {
            self.locationManager?.startUpdatingLocation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.locationManager?.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Map Methods
    
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
    
    @IBAction func updateMapType(_ sender: Any) {
        if(segmentedControlMapSelector.selectedSegmentIndex == 0){
            mapView.mapType = .standard
        }
        else if(segmentedControlMapSelector.selectedSegmentIndex == 1){
            mapView.mapType = .satellite
        }
        else if(segmentedControlMapSelector.selectedSegmentIndex == 2){
            mapView.mapType = .hybrid
        }
        else{
            mapView.mapType = .standard
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
    
    func clearMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    //MARK: - Scale Methods
    
    @IBAction func cancelButtonPushed(_ sender: Any) {
        if (readyToStart) {
            readyToStart = false
            placingCenter = false
            self.clearMap()
            self.positionRegionPoints()
            confirmButton.setTitle("Confirm Scale", for: .normal)
        }
        else if (!placingCenter) {
            readyToStart = false
            placingCenter = true
            self.clearMap()
            LongitudeSlider.isHidden = true;
            LatitudeSlider.isHidden = true;
            LongitudeLabel.isHidden = true;
            LatitudeLabel.isHidden = true;
            confirmButton.setTitle("Confirm Center", for: .normal)
        }
        else {
            performSegue(withIdentifier: "scaleToFlySegue", sender: nil)
        }
    }
    
    @IBAction func confirmButtonPushed(_ sender: Any) {
        if (placingCenter){
            self.center = mapView.annotations[0].coordinate
            print("ORIGIN (\(center?.latitude ?? 0), \(center?.longitude ?? 0))")
            confirmButton.setTitle("Confirm Scale", for: .normal)
            
            LongitudeSlider.isHidden = false;
            LatitudeSlider.isHidden = false;
            LongitudeLabel.isHidden = false;
            LatitudeLabel.isHidden = false;
            
            regionPins.append(MKPointAnnotation())
            regionPins.append(MKPointAnnotation())
            regionPins.append(MKPointAnnotation())
            regionPins.append(MKPointAnnotation())
            
            self.latitudeSliderChanged(self)
            self.longitudeSliderChanged(self)
            
            self.positionRegionPoints()
            
            placingCenter = false
            readyToStart = false
            
            
        }
        else if (!readyToStart) {
             latitudeScale = abs(regionPins[1].coordinate.latitude-regionPins[2].coordinate.latitude)/500
             longitudeScale = abs(regionPins[0].coordinate.longitude-regionPins[1].coordinate.longitude)/500
            
            confirmButton.setTitle("Start", for: .normal)
            
            LongitudeSlider.isHidden = true;
            LatitudeSlider.isHidden = true;
            LongitudeLabel.isHidden = true;
            LatitudeLabel.isHidden = true;
            
            readyToStart = true
        }
        else if (readyToStart) {
            print("Starting mission...")
            pathSelected()
            startMission()
        }
        else {
            print("Unknown State!!!")
        }
    }
    
    func positionRegionPoints() {
        regionPins[0].coordinate = CLLocationCoordinate2D(latitude: center!.latitude+latOffset, longitude: center!.longitude-lonOffset)
        regionPins[1].coordinate = CLLocationCoordinate2D(latitude: center!.latitude+latOffset, longitude: center!.longitude+lonOffset)
        regionPins[2].coordinate = CLLocationCoordinate2D(latitude: center!.latitude-latOffset, longitude: center!.longitude+lonOffset)
        regionPins[3].coordinate = CLLocationCoordinate2D(latitude: center!.latitude-latOffset, longitude: center!.longitude-lonOffset)
        
        self.clearMap()
        
        mapView.addAnnotation(regionPins[0])
        mapView.addAnnotation(regionPins[1])
        mapView.addAnnotation(regionPins[2])
        mapView.addAnnotation(regionPins[3])
        
        let region = MKPolygon(coordinates: [regionPins[0].coordinate, regionPins[1].coordinate, regionPins[2].coordinate, regionPins[3].coordinate], count: 4)
        
        mapView.addOverlay(region)
        
        let pin0 = CLLocation(latitude: regionPins[0].coordinate.latitude, longitude: regionPins[0].coordinate.longitude)
        let pin1 = CLLocation(latitude: regionPins[1].coordinate.latitude, longitude: regionPins[1].coordinate.longitude)
        let pin2 = CLLocation(latitude: regionPins[2].coordinate.latitude, longitude: regionPins[2].coordinate.longitude)
        
        var distance = pin1.distance(from: pin2)
        LatitudeLabel.text = "\(distance.rounded())m"
        distance = pin0.distance(from: pin1)
        LongitudeLabel.text = "\(distance.rounded())m"
    }
    
    @IBAction func latitudeSliderChanged(_ sender: Any) {
        latOffset = CLLocationDegrees(LatitudeSlider.value/222222)
        positionRegionPoints()
    }
    @IBAction func longitudeSliderChanged(_ sender: Any) {
        let cosine = cos((center?.latitude)!*Double.pi/180)
        let den: Float = Float(222222*cosine)
        lonOffset = CLLocationDegrees(LongitudeSlider.value/den)
        positionRegionPoints()
    }
    
    //MARK: Start Sequence Methods
    
    func pathSelected () {
        var scaledPoint:(CLLocationCoordinate2D,Float)
        
        var lat:Double?
        var long:Double?
        
        for i in 0...path.count - 1{
            if(i%3 == 0)
            {
                long = Double(path[i]) * longitudeScale + center!.longitude
            }
            else if(i%3 == 1)
            {
                lat = Double(path[i]) * latitudeScale + center!.latitude
                
            }
            else if(i%3 == 2)
            {
                scaledPoint.1 = path[i] / 3.28
                scaledPoint.0 = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                waypoints.append(DJIWaypoint(coordinate: scaledPoint.0))
                waypoints[i/3].altitude = scaledPoint.1
                mutablemission.add(waypoints[i/3])
            }
            print("\n \(i)" + ", ")
            print(mutablemission.waypointCount)
            
            var error = mutablemission.checkValidity()
            if (error != nil) {
                print(error!.localizedDescription)
            }
            else {
                print("Mission is valid!!!")
            }
            error = mutablemission.checkParameters()
            if (error != nil) {
                print(error!.localizedDescription)
            }
            else {
                print("Mission is checked!!!")
            }
        }
    }
    
    func startMission() {
        let startCompletionHandler: (_ error: Error?) -> Void = { (error) -> Void in
            if (error == nil) {
                startDidComplete()
            }
        }
        
        let uploadCompletionHandler: (_ error: Error?) -> Void = { (error) -> Void in
            if (error != nil) {
                self.missionOperator!.startMission(completion: startCompletionHandler)
            }
        }
        
        mutablemission.maxFlightSpeed = 15
        //mutablemission.autoFlightSpeed = speedSliderOutlet.value
        mutablemission.headingMode = DJIWaypointMissionHeadingMode.auto
        mutablemission.finishedAction = DJIWaypointMissionFinishedAction.noAction
        
        mission = DJIWaypointMission(mission: mutablemission)
        
        missionOperator?.addListener(toUploadEvent: self, with: DispatchQueue.main, andBlock: { (event) in
            
            if event.error != nil {
                self.missionOperator?.uploadMission(completion: uploadCompletionHandler)
            }
            else {
                // start mission
                self.missionOperator?.startMission(completion: startCompletionHandler)
            }
            
        })
        
        
        missionOperator!.load(mission)
        
        missionOperator!.uploadMission(completion: uploadCompletionHandler)
        
        func startDidComplete () {
            //let alert = UIAlertController(title: "Start Completed!", message: "", preferredStyle: .alert)
            //alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            //self.present(alert, animated: true)
            performSegue(withIdentifier: "scaleToFlySegue", sender: nil)
        }
    }
}
