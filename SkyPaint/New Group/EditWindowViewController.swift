import UIKit
import SpriteKit
import CoreData

class EditWindowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate {
    
    var points:[(Float, Float, Float)] = []
    var plane:String = "XY"
    var updateRow:Int = 0
    var numPoints:Int = 0;
    
    var xCord:Float = 0.0
    var yCord:Float = 0.0
    var zCord:Float = 0.0
    
    var scale:Float = 0.0
    var zScale:Float = 0.0
    
    var modified = false
    var isNewPointToAdd = false
    var isTextBoxEditing = false
    var isUpdatingPoint = false
        
    @IBOutlet weak var pDV: pathDisplayView!
    
    
    @IBOutlet weak var yzOutlet: UIButton!
    @IBOutlet weak var xzOutlet: UIButton!
    @IBOutlet weak var xyOutlet: UIButton!
    
    @IBOutlet weak var pathNameTextFeild: UITextField!
    
    
    //***************************************TextFields and Sliders**************************************
    
    @IBOutlet weak var addUpdateBtn: UIButton!
    @IBOutlet weak var sliderText: UILabel!
    @IBOutlet weak var dynamicSlider: UISlider!
    
    
    @IBAction func zSliderChanged(_ sender: UISlider) { //Updates text outlets and golabl cordiantes when slider is changed
        if(plane == "XY"){
            sliderText.text = "Z:"
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
        
        //updates point with new slider axis value
        var tmpPoint:(Float, Float, Float)
        
        tmpPoint = (xCord, yCord, zCord)
        
        if (points.count == numPoints + 1){
            points.remove(at: numPoints)
        }
        points.append(tmpPoint)
        
        pDV.points = self.points
        pDV.setNeedsDisplay()
        
    }
    
    
    @IBOutlet weak var pointTableView: UITableView!
    
    
    
    //    ********************************************Buttons***********************************************
    
    @IBAction func returnToMain(_ sender: Any) {
        performSegue(withIdentifier: "createToMainMenuSegue", sender: nil)
    }
    
    
    @IBAction func unwindToCreate(segue:UIStoryboardSegue) {
        modified = false
        pDV.scale = self.scale
        pDV.zScale = self.zScale
        pDV.points = self.points
        pDV.setNeedsDisplay()
    }
    
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
            
//             points[updateRow].0 = xSlider.value
//             points[updateRow].1 = ySlider.value
//             points[updateRow].2 = zSlider.value
             self.pointTableView.reloadData()
             pDV.points = self.points
             pDV.setNeedsDisplay()
             
             let indexPath:IndexPath = IndexPath(item: updateRow, section: 1)
             
             pointTableView.deselectRow(at: indexPath, animated: true)
            isUpdatingPoint = false
            addUpdateBtn.setTitle("Add Point", for: .normal)
        }
    }
    
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
                    latitude.append(point.0)
                    longitude.append(point.1)
                    altitude.append(point.2)
                }
                
                newPath.latitude = latitude as NSObject
                newPath.longitude = longitude as NSObject
                newPath.altitude = altitude as NSObject
                
                appDelegate.saveContext()
                
                performSegue(withIdentifier: "createToPathSegue", sender: nil)
            }
        }
        else{
            var message:String = ""
            if(pathNameTextFeild.text == nil || pathNameTextFeild.text == ""){
                message = "Please enter a unique path name"
                if(points.count < 2){
                    message.append(" and have at least two waypoints")
                }
            }
            if(points.count < 2){
                message = "Please have at least two waypoints"
            }
            if(isDuplicate){
                message = "Please have a unique flight path name"
            }
            
            let alertController = UIAlertController(title: "Error:", message:
                "\(message)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
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
    
    //*********************TableView Functions***************************
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { //Deleting a point from tableview
        if editingStyle == UITableViewCell.EditingStyle.delete {
            points.remove(at: indexPath.row)
            numPoints -= 1
            pDV.points = self.points
            pDV.setNeedsDisplay();
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // Counts number of points to populate
        return numPoints
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //Provides data to tableview
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointCellIdentifier", for: indexPath)
        
        let text:String = "X: " + (String)(describing: points[indexPath.row].0.rounded()) + ", Y: " + (String)(describing: points[indexPath.row].1.rounded()) + ", Z: " + (String)(describing: points[indexPath.row].2.rounded())
        
        cell.textLabel?.text = text
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //Selecting a row
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
    
    //******************************************Gesture Recognition*******************************************
    
    @IBAction func panPiece(_ gestureRecognizer : UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        let location = gestureRecognizer.location(in: gestureRecognizer.view!)
        // Update the position for the .began, .changed, and .ended states
        if gestureRecognizer.state != .cancelled {
            if (location.x > 0 && location.y > 0 && location.x < pDV.frame.width && location.y < pDV.frame.height) {
                pDV.scale = scale
                pDV.zScale = zScale
                let newPoint:CGPoint = location


                if(plane == "XY") //tests for plane
                {

                    xCord = scale * Float(newPoint.x)-250 //changes Cordiantes to standard -250,250 scale,
                    yCord = (scale * Float(newPoint.y)) * -1 + 250

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
                }
                else if(plane == "XZ")
                {
                    xCord = scale * Float(newPoint.x)-250
                    zCord = (zScale * Float(newPoint.y)) * -1 + 400

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
                }
                else if(plane == "YZ")
                {
                    yCord = (scale * Float(newPoint.x)) - 250
                    zCord = (zScale * Float(newPoint.y)) * -1 + 400

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
                }

                var tmpPoint:(Float, Float, Float)



                tmpPoint = (xCord, yCord, zCord)


                if(isUpdatingPoint){
                    points[updateRow] = tmpPoint
                }
                else{
                    points.append(tmpPoint)
                }
                pDV.points = self.points
                pDV.setNeedsDisplay()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isTextBoxEditing = true
    }
    
    
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


            if(plane == "XY") //tests for plane
            {

                xCord = scale * Float(newPoint.x)-250 //changes Cordiantes to standard -250,250 scale,
                yCord = (scale * Float(newPoint.y)) * -1 + 250

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
            }
            else if(plane == "XZ")
            {
                xCord = scale * Float(newPoint.x)-250
                zCord = (zScale * Float(newPoint.y)) * -1 + 400

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
            }
            else if(plane == "YZ")
            {
                yCord = (scale * Float(newPoint.x)) - 250
                zCord = (zScale * Float(newPoint.y)) * -1 + 400

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
            }

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

            pDV.points = self.points
            pDV.setNeedsDisplay()
        }

    }
    
    override func viewDidAppear(_ animated: Bool) { //sets scale of pDV based on screen size
        scale = Float(500 / pDV.frame.width)
        zScale = Float(400 / pDV.frame.width)
    }
    
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
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        let addPointGesture = UITapGestureRecognizer(target: self, action: #selector (EditWindowViewController.tapToPoint(_:)))
        addPointGesture.addTarget(self.view, action: #selector(UIView.endEditing(_:)))
        let addPanGesture = UIPanGestureRecognizer(target: self, action: #selector (EditWindowViewController.panPiece(_:)))
        pDV.addGestureRecognizer(addPointGesture)
        pDV.addGestureRecognizer(addPanGesture)
        pDV.scale = scale
        
        //        updatePointButtonOutlet.isEnabled = false
        //
        //        verticalAxisLabel.text = "Y-Axis"
        //        horizantalAxisLabel.text = "X-Axis"
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
