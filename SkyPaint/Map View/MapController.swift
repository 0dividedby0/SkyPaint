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
   
    //UI Variables
    @IBOutlet weak var LatitudeSlider: UISlider!
    @IBOutlet weak var LatitudeLabel: UILabel!
    @IBOutlet weak var LongitudeSlider: UISlider!
    @IBOutlet weak var LongitudeLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var segmentedControlMapSelector: UISegmentedControl!
    
    @IBOutlet weak var pathConfirmationView: UIView!
    @IBOutlet weak var pathDistanceLabel: UILabel!
    @IBOutlet weak var pathSpeedLabel: UILabel!
    @IBOutlet weak var pathTimeLabel: UILabel!
    @IBOutlet weak var pathSpeedSlider: UISlider!
    
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
    var path: RawPathMO!
    var waypoints: [DJIWaypoint] = []
    var totalDistance = 0.00
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
        confirmButton.setTitle("Confirm Center", for: .normal) // initial confirm button text
        mapView.mapType = .standard // initializes map in standard view
    }
    
    override var prefersStatusBarHidden: Bool {
        return true //hide the time/status bar for this view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.userLocation = kCLLocationCoordinate2DInvalid
        
        let touchEvent = UITapGestureRecognizer(target: self, action: #selector(MapController.mapTap(_:)))
        mapView.addGestureRecognizer(touchEvent)
        
        //set MapController as mapView and locationManager delegate
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
            self.clearMap()
            let newPin = MKPointAnnotation()
            newPin.coordinate = userLocation
            mapView.addAnnotation(newPin)
            
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
            renderer.fillColor = UIColor.black.withAlphaComponent(0.3)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
        }
        else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.white
            renderer.lineWidth = 2
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    func clearMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    //MARK: - User Interaction Methods
    
    @IBAction func cancelButtonPushed(_ sender: Any) {
        if (readyToStart) {
            //On "Start" step, move back to "Confirm Scale" step
            
            //Update UI (Clear map, show scale sliders, and hide path confirmation view)
            self.clearMap()
            LongitudeSlider.isHidden = false;
            LatitudeSlider.isHidden = false;
            LongitudeLabel.isHidden = false;
            LatitudeLabel.isHidden = false;
            pathConfirmationView.isHidden = true;
            //Place scale region back on map
            self.positionRegionPoints()
            //Update status variables
            readyToStart = false
            placingCenter = false
            //Update confirm button text
            confirmButton.setTitle("Confirm Scale", for: .normal)

            //Hide path metrics view (distance, speed, time)
        }
        else if (!placingCenter) {
            //On "Confirm Scale" step, move back to "Confirm Center" step
            
            //Update UI (Clear map and hide scale sliders)
            self.clearMap()
            
            LongitudeSlider.isHidden = true;
            LatitudeSlider.isHidden = true;
            LongitudeLabel.isHidden = true;
            LatitudeLabel.isHidden = true;
            //Place center pin back on map
            let newPin = MKPointAnnotation()
            newPin.coordinate = center!
            mapView.addAnnotation(newPin)
            //Update status variables
            readyToStart = false
            placingCenter = true
            //Update confirm button text
            confirmButton.setTitle("Confirm Center", for: .normal)
        }
        else {
            //On "Confirm Center" step, move back to Flight View
            performSegue(withIdentifier: "scaleToConfirmationSegue", sender: nil)
        }
    }
    
    @IBAction func confirmButtonPushed(_ sender: Any) {
        if (placingCenter){
            //On "Confirm Center" step, move to "Confirm Scale" step
            
            //Record and print out selected center point
            self.center = mapView.annotations[0].coordinate
            print("ORIGIN (\(center?.latitude ?? 0), \(center?.longitude ?? 0))")
            
            //Update UI (show scale sliders, get slider values, add scale region to map)
            LongitudeSlider.isHidden = false;
            LatitudeSlider.isHidden = false;
            LongitudeLabel.isHidden = false;
            LatitudeLabel.isHidden = false;
            
            regionPins.append(MKPointAnnotation()) //Initialize regionPins array with 4 elements
            regionPins.append(MKPointAnnotation())
            regionPins.append(MKPointAnnotation())
            regionPins.append(MKPointAnnotation())
            
            self.latitudeSliderChanged(self)
            self.longitudeSliderChanged(self)
            
            self.positionRegionPoints()
            
            //Update status variables
            placingCenter = false
            readyToStart = false
            
            //Update confirm button text
            confirmButton.setTitle("Confirm Scale", for: .normal)
        }
        else if (!readyToStart) {
            //On "Confirm Scale" step, move to "Start" step
            
            //Record longitude and latitude scale, difference/500 unit scale used when editing
            latitudeScale = abs(regionPins[1].coordinate.latitude-regionPins[2].coordinate.latitude)/500
            longitudeScale = abs(regionPins[0].coordinate.longitude-regionPins[1].coordinate.longitude)/500
            

            //Generate a waypoint mission with given scale

            pathSelected()
            
            //Update distance, speed, and time labels
            let waypoints = mutablemission.allWaypoints()
            

            totalDistance = 0.00;   //Distance
            for i: Int in 0..<(Int(mutablemission.waypointCount-1)) {
                let from = CLLocation(latitude: waypoints[i].coordinate.latitude, longitude: waypoints[i].coordinate.longitude)
                let to = CLLocation(latitude: waypoints[i+1].coordinate.latitude, longitude: waypoints[i+1].coordinate.longitude)
                let horizontalDistance = from.distance(from: to).magnitude
                let verticalDistance = abs(waypoints[i].altitude-waypoints[i+1].altitude)
                totalDistance += sqrt(pow(horizontalDistance,2)+Double(pow(verticalDistance,2)))
            }
            pathDistanceLabel.text = String(format: "%.1f", totalDistance) + " m"
            

            mutablemission.autoFlightSpeed = pathSpeedSlider.value; //Speed
            pathSpeedLabel.text = String(format: "%.1f", mutablemission.autoFlightSpeed) + " m/s"
            
            let seconds = Int((Float(totalDistance)/mutablemission.autoFlightSpeed).rounded()+Float(5*mutablemission.waypointCount)) //Time
            let remainingSeconds = seconds % 60
            let minutes = seconds/60
            pathTimeLabel.text = "\(minutes)m \(remainingSeconds)s"
            
            //Update UI (hide scale sliders, show path confirmation view)
            LongitudeSlider.isHidden = true
            LatitudeSlider.isHidden = true
            LongitudeLabel.isHidden = true
            LatitudeLabel.isHidden = true
            pathConfirmationView.isHidden = false
            
            //Update status variables
            readyToStart = true
            
            //Update confirm button text
            confirmButton.setTitle("Start", for: .normal)
        }
        else if (readyToStart) {

            //On "Start" step, start mission
            print("Starting mission...");
            startMission()
        }
        else {
            print("Unknown State!!!")
        }
    }
    
    //Update scaled region and path on map
    func positionRegionPoints() {
        //Set corner pins based on confirmed center location and scale slider values (offets)
        regionPins[0].coordinate = CLLocationCoordinate2D(latitude: center!.latitude+latOffset, longitude: center!.longitude-lonOffset)
        regionPins[1].coordinate = CLLocationCoordinate2D(latitude: center!.latitude+latOffset, longitude: center!.longitude+lonOffset)
        regionPins[2].coordinate = CLLocationCoordinate2D(latitude: center!.latitude-latOffset, longitude: center!.longitude+lonOffset)
        regionPins[3].coordinate = CLLocationCoordinate2D(latitude: center!.latitude-latOffset, longitude: center!.longitude-lonOffset)
        
        //Update map (clear, draw scaled region)
        self.clearMap()
        let region = MKPolygon(coordinates: [regionPins[0].coordinate, regionPins[1].coordinate, regionPins[2].coordinate, regionPins[3].coordinate], count: 4)
        mapView.addOverlay(region)
        
        //Update slider distance labels based on actual distance between pins
        let pin0 = CLLocation(latitude: regionPins[0].coordinate.latitude, longitude: regionPins[0].coordinate.longitude)
        let pin1 = CLLocation(latitude: regionPins[1].coordinate.latitude, longitude: regionPins[1].coordinate.longitude)
        let pin2 = CLLocation(latitude: regionPins[2].coordinate.latitude, longitude: regionPins[2].coordinate.longitude)
        
        var distance = pin1.distance(from: pin2)
        LatitudeLabel.text = "\(distance.rounded())m"
        distance = pin0.distance(from: pin1)
        LongitudeLabel.text = "\(distance.rounded())m"
        
        //Record longitude and latitude scale, distance difference/500 unit scale used when editing
        latitudeScale = abs(regionPins[1].coordinate.latitude-regionPins[2].coordinate.latitude)/500
        longitudeScale = abs(regionPins[0].coordinate.longitude-regionPins[1].coordinate.longitude)/500
        
        //Generate scaled path using scale values and selected path data
        var scaledPoint:(CLLocationCoordinate2D,Float)
        var tempScaledPath: [CLLocationCoordinate2D] = []
        
        var lat:Double?
        var long:Double?
        
        for i: Int in 0...(path.numPoints as! Int)-1 {
            
            long = Double((path.longitude as! [Float])[i]) * longitudeScale + center!.longitude
            lat = Double((path.latitude as! [Float])[i]) * latitudeScale + center!.latitude
            
            scaledPoint.1 = (path.altitude as! [Float])[i] / 3.28 //convert feet to meters
            scaledPoint.0 = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            tempScaledPath.append(scaledPoint.0)
            
            if (i == 0) {
                let startingPoint = MKPointAnnotation()
                startingPoint.coordinate = scaledPoint.0
                startingPoint.title = "start"
                mapView.addAnnotation(startingPoint)
            }
            else if (i == (path.numPoints as! Int)-1) {
                let finishPoint = MKPointAnnotation()
                finishPoint.coordinate = scaledPoint.0
                finishPoint.title = "finish"
                mapView.addAnnotation(finishPoint)
            }
        }
        
        //Draw scaled path on map inside scaled region
        let scaledPathView = MKPolyline(coordinates: tempScaledPath, count: tempScaledPath.count)
        
        mapView.addOverlay(scaledPathView)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        else if (annotation.title == "start") {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "marker")
            pinView.pinTintColor = .green
            pinView.canShowCallout = false
            return pinView
        }
        else if (annotation.title == "finish") {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "marker")
            pinView.pinTintColor = .red
            pinView.canShowCallout = false
            return pinView
        }
        
        return nil
    }
    
    
    @IBAction func latitudeSliderChanged(_ sender: Any) {
        //Convert meters to latitude and update mapview
        latOffset = CLLocationDegrees(LatitudeSlider.value/222222)
        positionRegionPoints()
    }
    @IBAction func longitudeSliderChanged(_ sender: Any) {
        //convert meters to longitude, based on latitude of center, and update mapview
        let cosine = cos((center?.latitude)!*Double.pi/180)
        let den: Float = Float(222222*cosine)
        lonOffset = CLLocationDegrees(LongitudeSlider.value/den)
        positionRegionPoints()
    }
    
    @IBAction func pathSpeedSliderChanged(_ sender: Any) {

        //Update mission speed and speed label
        mutablemission.autoFlightSpeed = pathSpeedSlider.value;
        pathSpeedLabel.text = String(format: "%.1f", mutablemission.autoFlightSpeed) + " m/s"
        
        //Update time label
        let seconds = Int((Float(totalDistance)/mutablemission.autoFlightSpeed).rounded()+Float(5*mutablemission.waypointCount))
        let remainingSeconds = seconds % 60
        let minutes = seconds/60
        pathTimeLabel.text = "\(minutes)m \(remainingSeconds)s"
    }
    

    //MARK: - Start Sequence Methods
    
    func pathSelected () {
        //Generate waypoint mission using scale values and selected path data
        var scaledPoint:(CLLocationCoordinate2D,Float)
        
        var lat:Double?
        var long:Double?
        
        for i: Int in 0...(path.numPoints as! Int)-1 {
            long = Double((path.longitude as! [Float])[i]) * longitudeScale + center!.longitude
            lat = Double((path.latitude as! [Float])[i]) * latitudeScale + center!.latitude
            
            scaledPoint.1 = (path.altitude as! [Float])[i] / 3.28
            scaledPoint.0 = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            waypoints.append(DJIWaypoint(coordinate: scaledPoint.0))
            waypoints[i].altitude = scaledPoint.1
            mutablemission.add(waypoints[i])
            
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
        if (DJISDKManager.product() == nil) {
            let alert = UIAlertController(title: "No Connection!", message: "Please connect to a DJI aircraft first.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else {
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
            mutablemission.headingMode = DJIWaypointMissionHeadingMode.auto
            mutablemission.finishedAction = DJIWaypointMissionFinishedAction.noAction
            
            //convert mutable mission to standard mission
            mission = DJIWaypointMission(mission: mutablemission)
            
            missionOperator?.addListener(toUploadEvent: self, with: DispatchQueue.main, andBlock: { (event) in
                
                if event.error != nil {
                    //request upload until no error
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
                print("Mission Started!!!")
                performSegue(withIdentifier: "scaleToFlySegue", sender: nil)
            }
        }
    }
}
