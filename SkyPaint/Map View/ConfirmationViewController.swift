//
//  ConfirmationViewController.swift
//  SkyPaint
//
//  Created by Jason Halcomb on 3/4/18.
//  Copyright © 2018 SkyPaint. All rights reserved.
//

import UIKit
import MapKit
import DJISDK

class ConfirmationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

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
    
    @IBOutlet weak var pathNamesTableView: UITableView!
    @IBOutlet weak var speedSliderOutlet: UISlider!
    @IBOutlet weak var locationLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (pathNames?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pathNameIdentifier", for: indexPath)
        
        cell.textLabel?.text = pathNames?[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        path = UserDefaults.standard.array(forKey: pathNames![indexPath.row]) as! [Float]
        
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
    
    @IBAction func speedSliderChange(_ sender: UISlider) {
    }
    
    @IBAction func startButtonTouched(_ sender: UIButton) {
        startMission()
        //performSegue(withIdentifier: "confirmationToStartSegue", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pathNamesTableView.dataSource = self
        pathNamesTableView.delegate = self
        
        pathNames = (UserDefaults.standard.array(forKey: "PathNames") as! [String])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        mutablemission.autoFlightSpeed = speedSliderOutlet.value
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
            let alert = UIAlertController(title: "Start Completed!", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
