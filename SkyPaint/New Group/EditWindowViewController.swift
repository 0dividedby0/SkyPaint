//
// EditWindowViewController.swift
// SkyPaint
//
// Created by Addisalem Kebede on 3/3/18.
// Most recent edit by Connor Easton on 2/26/19
//
// Copyright © 2018 SkyPaint. All rights reserved.
//

import UIKit
import SpriteKit
import CoreData

class EditWindowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Variables
    
    var points:[(Float, Float, Float)] = [] /// points displayed on pDV and tableView
    var plane:String = "XY"         /// tracks what xyz plane should be displayed
    var updateRow:Int = 0           /// tracks what point is being updated if updating
    var numPoints:Int = 0;          /// tracks num points *Different from points.count*
    
    var xCord:Float = 0.0           /// current x coordinate
    var yCord:Float = 0.0           /// current y coordinate
    var zCord:Float = 0.0           /// current z coordinate
    
    var scale:Float = 0.0           /// scale of x and y determined by device screen size
    var zScale:Float = 0.0          /// scale of z determined by device scren size
    
    var modified = false            /// tracks if pDV has points that has not been saved
    var isNewPointToAdd = false     /// tracks if a new point has been added to pDV but not pushed to points[]
    var isTextBoxEditing = false    /// tracks if keyboard is being displayed
    var isUpdatingPoint = false     /// tracks if a point has been tapped on tableview for updating
    
    // MARK: - UI Outlets
    
    @IBOutlet weak var pDV: pathDisplayView!
    
    @IBOutlet weak var yzOutlet: UIButton!
    @IBOutlet weak var xzOutlet: UIButton!
    @IBOutlet weak var xyOutlet: UIButton!
    
    @IBOutlet weak var pathNameTextFeild: UITextField!
    
    @IBOutlet weak var addUpdateBtn: UIButton!
    @IBOutlet weak var sliderText: UILabel!
    @IBOutlet weak var dynamicSlider: UISlider!
    @IBOutlet weak var pointTableView: UITableView!
    
    // MARK: - Textfields/Sliders
    
    /*******************************************************************************
     // Function: textFieldDidBeginEditing
     // Called when: textbox for path name is tapped
     // Usage: to keep track of whether or not keyboard is being displayed
     ********************************************************************************/
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isTextBoxEditing = true
    }
    
    /*******************************************************************************
     // Function: zSliderChanged
     // Called when: dynamic slider has been chagned
     // Usage: to update corresponding slider X/Y/S, slider amount,
     //    update global tmpPoint variable for pDV with new slider information
     ********************************************************************************/
    @IBAction func zSliderChanged(_ sender: UISlider) {
        if(plane == "XY"){
            sliderText.text = "Z: "
            zCord = dynamicSlider.value
        }
        else if(plane == "XZ"){
            sliderText.text = "Y: "
            yCord = dynamicSlider.value
            
        }
        else if(plane == "YZ"){
            sliderText.text = "X: "
            xCord = dynamicSlider.value
            
        }
        sliderText.text?.append("\(Int(dynamicSlider.value))")
        
        var tmpPoint:(Float, Float, Float)
        tmpPoint = (xCord, yCord, zCord)
        
        if (points.count == numPoints + 1){
            points.remove(at: numPoints)
        }
        if(isUpdatingPoint){
            points[updateRow] = tmpPoint
        }
        else{
            points.append(tmpPoint)
        }
        
        pDV.points = self.points  /// Updates pDV
        pDV.setNeedsDisplay()
    }
    
    // MARK: - Button Actions
    
    /*******************************************************************************
     // Function: returnToMain
     // Called when: back button has been pressed
     // Usage: to return to main menu
     ********************************************************************************/
    @IBAction func returnToMain(_ sender: Any) {
        performSegue(withIdentifier: "createToMainMenuSegue", sender: nil)
    }
    
    /*******************************************************************************
     // Function: xzButtonTapped
     // Called when: XZ button has been pressed
     // Usage: to update pDV to display coordinates on an XZ plane, set slider
     //     to Y axis and value
     ********************************************************************************/
    @IBAction func xzButtonTapped(_ sender: UIButton) { //sets plane to XZ axis and sets correspoing sliders
        plane = "XZ"
        pDV.plane = "XZ"
        pDV.setNeedsDisplay()
        dynamicSlider.minimumValue = -250
        dynamicSlider.maximumValue = 250
        
        if(points.count > 0)
        {
            dynamicSlider.value = points[points.count-1].1 //getting the previous points y value
            yCord = dynamicSlider.value
            sliderText.text = "Y: \(Int(dynamicSlider.value))"
        }
        else
        {
            dynamicSlider.value = 0
            yCord = dynamicSlider.value
            sliderText.text = "Y: \(Int(dynamicSlider.value))"
        }
        
        
        
        xyOutlet.tintColor = xzOutlet.tintColor
        yzOutlet.tintColor = xzOutlet.tintColor
        xzOutlet.tintColor = UIColor.green
        
    }
    
    /*******************************************************************************
     // Function: yzButtonTapped
     // Called when: YZ button has been pressed
     // Usage: to update pDV to display coordinates on an YZ plane, set slider
     //     to X axis and value
     ********************************************************************************/
    @IBAction func yzButtonTapped(_ sender: UIButton) {//sets plane to YZ axis and sets correspoing sliders
        plane = "YZ"
        pDV.plane = "YZ"
        pDV.setNeedsDisplay()
        dynamicSlider.minimumValue = -250
        dynamicSlider.maximumValue = 250
        
        if(points.count > 0)
        {
            dynamicSlider.value = points[points.count-1].0//getting the previous points x value
            xCord = dynamicSlider.value
            sliderText.text = "X: \(Int(dynamicSlider.value))"
        }
        else
        {
            dynamicSlider.value = 0
            xCord = dynamicSlider.value
            sliderText.text = "X: \(Int(dynamicSlider.value))"
        }
        
        xzOutlet.tintColor = yzOutlet.tintColor
        xyOutlet.tintColor = yzOutlet.tintColor
        yzOutlet.tintColor = UIColor.green
    }
    
    /*******************************************************************************
     // Function: xyButtonTapped
     // Called when: XY button has been pressed
     // Usage: to update pDV to display coordinates on an XY plane, set slider
     //     to Z axis and value
     ********************************************************************************/
    @IBAction func xyButtonTapped(_ sender: UIButton) {//sets plane to XY axis and sets correspoing sliders
        plane = "XY"
        pDV.plane = "XY"
        pDV.setNeedsDisplay()
        dynamicSlider.minimumValue = 20
        dynamicSlider.maximumValue = 400
        
        if(points.count > 0)
        {
            dynamicSlider.value = points[points.count-1].2//getting the previous points z value
            zCord = dynamicSlider.value
            sliderText.text = "Z: \(Int(dynamicSlider.value))"
        }
        else
        {
            dynamicSlider.value = 20
            zCord = dynamicSlider.value
            sliderText.text = "Z: \(Int(dynamicSlider.value))"
        }
        
        
        xzOutlet.tintColor = xyOutlet.tintColor
        yzOutlet.tintColor = xyOutlet.tintColor
        xyOutlet.tintColor = UIColor.green
    }
    
    /*******************************************************************************
     // Function: addPointButtonTapped
     // Called when: the add point button or update button has been pressed
     // Usage: to update the local value of points[] to align with pDV.points and
     //     add new value to tableView.
     ********************************************************************************/
    @IBAction func addPointButtonTapped(_ sender: UIButton) {
        if(isNewPointToAdd){
            modified = true
            if(!isUpdatingPoint){
                numPoints += 1
            }
            
            if(plane == "XY"){
                sliderText.text = "Z: "
            }
            else if(plane == "XZ"){
                sliderText.text = "Y: "
            }
            else if(plane == "YZ"){
                sliderText.text = "X: "
            }
            sliderText.text?.append("\(Int(dynamicSlider.value))")
            
            self.pointTableView.reloadData()
            isNewPointToAdd = false;
        }
        if(isUpdatingPoint){
            if(plane == "XY"){
                sliderText.text = "Z: "
                dynamicSlider.value = points[updateRow].2
            }
            else if(plane == "XZ"){
                sliderText.text = "Y: "
                dynamicSlider.value = points[updateRow].1
            }
            else if(plane == "YZ"){
                sliderText.text = "X: "
                dynamicSlider.value = points[updateRow].0
                
            }
            sliderText.text?.append("\(Int(dynamicSlider.value))")
            
            self.pointTableView.reloadData()
            pDV.points = self.points
            pDV.setNeedsDisplay()
            
            let indexPath:IndexPath = IndexPath(item: updateRow, section: 1)
            
            pointTableView.deselectRow(at: indexPath, animated: true)
            isUpdatingPoint = false
            addUpdateBtn.setTitle("Add Point", for: .normal)
        }
    }
    
    /*******************************************************************************
     // Function: loadPath
     // Called when: the load path button has been pressed
     // Usage: to load a previously created path, clear any discrepencies between
     //     points[] and pDV.points[], warn user if current path has not been saved
     ********************************************************************************/
    @IBAction func loadPath(_ sender: Any) {
        if (points.count > numPoints){
            points.removeLast()
        }
        if (!modified) {
            performSegue(withIdentifier: "createToPathSegue", sender: nil)
        }
        else {
            let alertController = UIAlertController(title: "Error:", message:
                "Current path has not been saved", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /*******************************************************************************
     // Function: savePath
     // Called when: Save Path button has been pressed
     // Usage: - to check if flight path has all necessary variables
     //        - if so, add flightpath to RawPathMO[]
     //        - if path has same name as previously saved path, warn and give
     //          option to overwrite
     ********************************************************************************/
    @IBAction func savePath(_ sender: UIButton) {
        var paths: [RawPathMO] = []
        
        var fetchResultController: NSFetchedResultsController<RawPathMO>!
        
        let fetchRequest: NSFetchRequest<RawPathMO> = RawPathMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    paths = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
        
        var newPath: RawPathMO!
        var latitude: [Float] = [], longitude: [Float] = [], altitude: [Float] = []
        var isDuplicate:Bool = false
        
        if (points.count > numPoints){
            points.removeLast()
        }
        
        for path in paths{
            if(path.name == pathNameTextFeild.text){
                isDuplicate = true
                break
            }
        }
        
        if (pathNameTextFeild.text != nil && pathNameTextFeild.text != "" && points.count >= 2 && isDuplicate == false){
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                newPath = RawPathMO(context: appDelegate.persistentContainer.viewContext)
                
                newPath.name = pathNameTextFeild.text!
                newPath.numPoints = NSDecimalNumber(integerLiteral: points.count)
                
                for point in points {
                    latitude.append(point.1)
                    longitude.append(point.0)
                    altitude.append(point.2)
                }
                
                newPath.latitude = latitude as NSObject
                newPath.longitude = longitude as NSObject
                newPath.altitude = altitude as NSObject
                
                appDelegate.saveContext()
                
                modified = true
                performSegue(withIdentifier: "createToPathSegue", sender: nil)
            }
        }
        else{
            var nonDuplicateError = false
            var message:String = ""
            
            if(pathNameTextFeild.text == nil || pathNameTextFeild.text == ""){
                nonDuplicateError = true
                message = "Please enter a unique path name"
                if(points.count < 2){
                    message.append(" and have at least two waypoints")
                }
            }
            if(points.count < 2){
                message = "Please have at least two waypoints"
            }
            
            if(isDuplicate && !nonDuplicateError){
                let duplicateAlertController = UIAlertController(title: "Duplicate name detected!", message: "Are you sure you want to replace the existing flight path with the same name with this path?", preferredStyle: .alert )
                let overwriteBtn = UIAlertAction(title:"OVERWRITE", style: .default, handler:  {(_ action: UIAlertAction) -> Void in
                    
                    
                    
                    var matchLocation = 0 // duplicate path to delete index
                    for path in paths{
                        if(path.name == self.pathNameTextFeild.text){
                            break
                        }
                        matchLocation += 1
                    }
                    
                    var fetchResultController: NSFetchedResultsController<RawPathMO>!
                    
                    let fetchRequest: NSFetchRequest<RawPathMO> = RawPathMO.fetchRequest()
                    let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
                    fetchRequest.sortDescriptors = [sortDescriptor]
                    
                    if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                        
                        let context = appDelegate.persistentContainer.viewContext
                        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                        fetchResultController.delegate = self
                        
                        do {
                            try fetchResultController.performFetch()
                            if let fetchedObjects = fetchResultController.fetchedObjects {
                                paths = fetchedObjects
                            }
                        } catch {
                            print(error)
                        }
                        
                        let indexPath = IndexPath(row: matchLocation, section: 0)
                        let pathToDelete = fetchResultController.object(at: indexPath)
                        context.delete(pathToDelete)
                        
                        appDelegate.saveContext()
                        
                        newPath = RawPathMO(context: appDelegate.persistentContainer.viewContext)
                        
                        newPath.name = self.pathNameTextFeild.text!
                        newPath.numPoints = NSDecimalNumber(integerLiteral: self.points.count)
                        
                        for point in self.points {
                            latitude.append(point.1)
                            longitude.append(point.0)
                            altitude.append(point.2)
                        }
                        
                        newPath.latitude = latitude as NSObject
                        newPath.longitude = longitude as NSObject
                        newPath.altitude = altitude as NSObject
                        
                        appDelegate.saveContext()
                        
                        self.modified = true
                        self.performSegue(withIdentifier: "createToPathSegue", sender: nil)
                    }
                })
                
                let noBtn = UIAlertAction(title:"wait I want to go back...", style: .default, handler: nil)
                duplicateAlertController.addAction(overwriteBtn)
                duplicateAlertController.addAction(noBtn)
                self.present(duplicateAlertController, animated: true, completion: nil)
                
                
                if(nonDuplicateError){
                    let alertController = UIAlertController(title: "Error:", message:
                        "\(message)", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                nonDuplicateError = false
            }
        }
    }
    
    // MARK: - TableView Functions
    
    /*******************************************************************************
     // Called when: deleting a point from tableView
     // Usage: to delete selected point from global points[] and remove from list
     ********************************************************************************/
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            points.remove(at: indexPath.row)
            numPoints -= 1
            pDV.points = self.points
            pDV.setNeedsDisplay();
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
    /*******************************************************************************
     // Called when: parparing to populate tableView
     // Usage: to count how many rows will be filled with data
     ********************************************************************************/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numPoints
    }
    
    /*******************************************************************************
     // Called when: populating tableView
     // Usage: to populate tableView with points[] data
     ********************************************************************************/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointCellIdentifier", for: indexPath)
        
        let text:String = "X: " + (String)(describing: points[indexPath.row].0.rounded()) + ", Y: " + (String)(describing: points[indexPath.row].1.rounded()) + ", Z: " + (String)(describing: points[indexPath.row].2.rounded())
        
        cell.textLabel?.text = text
        
        return cell
    }
    
    /*******************************************************************************
     // Called when: user selects a row
     // Usage: - updates slider value to given point value
     //        - sets isUpdatingPoint to true
     //        - updates addpoint to Update point
     //        - enables updating/adjusting previously added points
     ********************************************************************************/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { ///Selecting a row
        if(points.count > indexPath.row)
        {
            
            
            xCord = points[indexPath.row].0
            yCord = points[indexPath.row].1
            zCord = points[indexPath.row].2
            
            
            if(plane == "XY"){
                sliderText.text = "Z: "
                dynamicSlider.value = zCord
                sliderText.text?.append("\(Int(dynamicSlider.value))")
                
            }
            else if(plane == "XZ"){
                sliderText.text = "Y: "
                dynamicSlider.value = yCord
                sliderText.text?.append("\(Int(dynamicSlider.value))")
                
            }
            else if(plane == "YZ"){
                sliderText.text = "X: "
                dynamicSlider.value = xCord
                sliderText.text?.append("\(Int(dynamicSlider.value))")
                
            }
            
            isUpdatingPoint = true
            addUpdateBtn.setTitle("Update Point", for: .normal)
            updateRow = indexPath.row
        }
    }
    
    // MARK: - Gesture Recognizers
    
    /*******************************************************************************
     // Function: panPiece
     // Called when: pDV has been dragged
     // Usage: to send new coordinates to newPointAt to add new location
     ********************************************************************************/
    @IBAction func panPiece(_ gestureRecognizer : UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        let location = gestureRecognizer.location(in: gestureRecognizer.view!)
        /// Update the position for the .began, .changed, and .ended states
        if gestureRecognizer.state != .cancelled {
            if (location.x > 0 && location.y > 0 && location.x < pDV.frame.width && location.y < pDV.frame.height) {
                pDV.scale = scale
                pDV.zScale = zScale
                let newPoint:CGPoint = location
                newPointAt(newPoint: newPoint)
            }
        }
    }
    
    /*******************************************************************************
     // Function: tapToPoint
     // Called when: pDV has been tapped
     // Usage: to send new coordinates to newPointAt to add new location
     ********************************************************************************/
    @objc func tapToPoint(_ sender:UITapGestureRecognizer)
    {
        if(isTextBoxEditing){
            isTextBoxEditing = false
        }
        else{
            isNewPointToAdd = true
            pDV.scale = scale
            pDV.zScale = zScale
            let newPoint:CGPoint = sender.location(in: self.pDV)
            newPointAt(newPoint: newPoint)
        }
    }
    
    
    // MARK: - Helper Functions
    
    /*******************************************************************************
     // Function: newPointAt
     // Called when: pDV has been tapped or panned
     // Usage: to create new point at tap locaiton on pDV
     ********************************************************************************/
    func newPointAt(newPoint:CGPoint){
        if(plane == "XY") //tests for plane and sets slider value to corresponding xyz value
        {
            
            xCord = scale * Float(newPoint.x)-250 ///changes Cordiantes to standard -250,250 scale,
            yCord = (scale * Float(newPoint.y)) * -1 + 250
            
            if(points.count > 0)
            {
                dynamicSlider.value = points[points.count-1].2 ///getting the previous points z value
                zCord = dynamicSlider.value
                sliderText.text = "Z: \(Int(dynamicSlider.value))"
            }
            else
            {
                dynamicSlider.value = 20
                zCord = dynamicSlider.value
                sliderText.text = "Z: \(Int(dynamicSlider.value))"
            }
        }
        else if(plane == "XZ")
        {
            xCord = scale * Float(newPoint.x)-250
            zCord = (zScale * Float(newPoint.y)) * -1 + 400
            
            if(points.count > 0)
            {
                dynamicSlider.value = points[points.count-1].1 ///getting the previous points y value
                yCord = dynamicSlider.value
                sliderText.text = "Y: \(Int(dynamicSlider.value))"
            }
            else
            {
                dynamicSlider.value = 0
                yCord = dynamicSlider.value
                sliderText.text = "Y: \(Int(dynamicSlider.value))"
            }
        }
        else if(plane == "YZ")
        {
            yCord = (scale * Float(newPoint.x)) - 250
            zCord = (zScale * Float(newPoint.y)) * -1 + 400
            
            if(points.count > 0)
            {
                dynamicSlider.value = points[points.count-1].0 ///getting the previous points x value
                xCord = dynamicSlider.value
                sliderText.text = "X: \(Int(dynamicSlider.value))"
            }
            else
            {
                dynamicSlider.value = 0
                xCord = dynamicSlider.value
                sliderText.text = "X: \(Int(dynamicSlider.value))"
            }
        }
        
        var tmpPoint:(Float, Float, Float)  /// new temporary point created with x,y,z coords
        tmpPoint = (xCord, yCord, zCord)
        
        if (points.count == numPoints + 1){ /// if points.count is greater than local count, remove last point since addButtonPressed has not been called
            points.remove(at: numPoints)
        }
        if(isUpdatingPoint){
            points[updateRow] = tmpPoint
        }
        else{
            points.append(tmpPoint)
        }
        
        pDV.points = self.points
        pDV.setNeedsDisplay() /// Refreshing pDV display
    }
    
    // MARK: - View Management
    
    /*******************************************************************************
     // Function: viewDidAppear
     // Called when: EditView page is loading
     // Usage: to calculate scale for pDV depending on screen size
     ********************************************************************************/
    override func viewDidAppear(_ animated: Bool) { ///sets scale of pDV based on screen size
        scale = Float(500 / pDV.frame.width)
        zScale = Float(400 / pDV.frame.width)
    }
    
    /*******************************************************************************
     // Function: viewDidLoad
     // Called when: EditView page is loading
     // Usage: to set and update global variabels to desired specifications
     ********************************************************************************/
    override func viewDidLoad() {
        
        super.viewDidLoad()
        pointTableView.dataSource = self
        pointTableView.delegate = self
        
        pathNameTextFeild.delegate = self
        
        dynamicSlider.maximumValue = 400
        dynamicSlider.minimumValue = 20
        modified = false
        
        
        dynamicSlider.value = 20
        sliderText.text = "Z: \(Int(dynamicSlider.value))"
        addUpdateBtn.setTitle("Add Point", for: .normal)
        
        
        xzOutlet.tintColor = xyOutlet.tintColor
        yzOutlet.tintColor = xyOutlet.tintColor
        xyOutlet.tintColor = UIColor.green
        
        // tap to dismiss keyboard
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tapToDismissKeyboard.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapToDismissKeyboard)
        
        let addPointGesture = UITapGestureRecognizer(target: self, action: #selector (EditWindowViewController.tapToPoint(_:)))
        addPointGesture.addTarget(self.view, action: #selector(UIView.endEditing(_:)))
        let addPanGesture = UIPanGestureRecognizer(target: self, action: #selector (EditWindowViewController.panPiece(_:)))
        pDV.addGestureRecognizer(addPointGesture)
        pDV.addGestureRecognizer(addPanGesture)
        pDV.scale = scale
    }
    
    /*******************************************************************************
     // Function: didReceiveMemoryWarning
     // Called when: device has run out of memory
     // Usage: to delete any unnecessary resources that can be recreated
     ********************************************************************************/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*******************************************************************************
     // Function: unwindToCreate
     // Called when: Returning to edit view
     // Usage: Updates pDV and pointTableView
     ********************************************************************************/
    @IBAction func unwindToCreate(segue:UIStoryboardSegue) {
        modified = false
        pDV.scale = self.scale
        pDV.zScale = self.zScale
        pDV.points = self.points
        pDV.setNeedsDisplay()
        self.pointTableView.reloadData()
    }
    
    /*******************************************************************************
     // Function: prepare
     // Called when: Preparing to change view
     // Usage: If moving to confirmation view, tell the destination view controller whether it's loading a path
     ********************************************************************************/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createToPathSegue" {
            let destinationController = segue.destination as! ConfirmationViewController
            destinationController.previousViewIsFlight = false
            if (!modified) {
                destinationController.loadingPath = true;
            }
            else {
                destinationController.loadingPath = false;
            }
        }
    }
    
}
