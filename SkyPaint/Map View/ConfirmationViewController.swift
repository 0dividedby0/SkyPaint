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

    //MARK: - Variable Declarations
    
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
    
    //MARK: - UIViewController Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pathNamesTableView.dataSource = self
        pathNamesTableView.delegate = self
        
        pathNames = (UserDefaults.standard.array(forKey: "PathNames") as? [String])
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (pathNames != nil ? pathNames!.count : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pathNameIdentifier", for: indexPath)
        
        cell.textLabel?.text = pathNames?[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        path = UserDefaults.standard.array(forKey: pathNames![indexPath.row]) as! [Float]
        
        performSegue(withIdentifier: "pathToScaleSegue", sender: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pathToScaleSegue" {
            let destinationController = segue.destination as! MapController
            destinationController.path = self.path
        }
    }

}
