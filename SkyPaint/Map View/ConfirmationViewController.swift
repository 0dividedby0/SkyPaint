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
    let mission:DJIMutableWaypointMission = DJIMutableWaypointMission()
    var path: [Float] = []
    var distanceInMeters: Double?
    var pathNames:[String]?
    var waypoint:DJIWaypoint = DJIWaypoint()
    
    @IBOutlet weak var pathNamesTableView: UITableView!
    @IBOutlet weak var speedSliderOutlet: UISlider!
    
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
                waypoint = DJIWaypoint(coordinate: scaledPoint.0)
                waypoint.altitude = scaledPoint.1
                mission.add(waypoint)
            }
            print("\n \(i)" + ", ")
            print(mission.allWaypoints().count)
        }
        let a = 5
    }
    
    @IBAction func speedSliderChange(_ sender: UISlider) {
    }
    
    @IBAction func startButtonTouched(_ sender: UIButton) {
        startMission()
        performSegue(withIdentifier: "confirmationToStartSegue", sender: nil)
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
        let missionOperator = DJISDKManager.missionControl()?.waypointMissionOperator()
        
        mission.maxFlightSpeed = 20
        mission.autoFlightSpeed = speedSliderOutlet.value
        mission.headingMode = DJIWaypointMissionHeadingMode.auto
        
        mission.finishedAction = DJIWaypointMissionFinishedAction.noAction
        
    
        
        missionOperator?.load(mission as DJIWaypointMission)
        
        missionOperator?.uploadMission(completion: nil)
        
        missionOperator?.startMission(completion: nil)
        
        
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
