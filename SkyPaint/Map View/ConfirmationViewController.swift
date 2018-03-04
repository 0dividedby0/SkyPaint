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

class ConfirmationViewController: UIViewController {

    var center: CLLocationCoordinate2D?
    var latitudeScale: Double?
    var longitudeScale: Double?
    let mission = DJIMutableWaypointMission()
    var path: [(Float,Float,Float)]?
    
    @IBOutlet weak var speedSliderOutlet: UISlider!
    
    override func viewWillAppear(_ animated: Bool) {
        path?.append((0, 0, 200))
        path?.append((0, 100, 250))
        path?.append((50, 100, 250))
        path?.append((50,0, 200))
        path?.append((0, 0, 250))
        
        //path = UserDefaults.standard.object(forKey: "Path1") as? [(Float, Float, Float)]
        
        var scaledPoint:(CLLocationCoordinate2D,Float)!
        
//        for point in path!{
//            scaledPoint.0 = CLLocationCoordinate2D(latitude: Double(point.1) * latitudeScale! + center!.latitude, longitude: Double(point.0) * longitudeScale! + center!.longitude)
//            scaledPoint.1 = point.2 / 3.28
//            let waypoint = DJIWaypoint(coordinate: scaledPoint.0)
//            waypoint.altitude = scaledPoint.1
//            mission.add(waypoint)
//        }
        
        
    }
    
    @IBAction func speedSliderChange(_ sender: UISlider) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
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
        
        missionOperator?.load(mission)
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
