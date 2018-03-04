//
//  EditWindowViewController.swift
//  SkyPaint
//
//  Created by Addisalem Kebede on 3/3/18.
//  Copyright © 2018 SkyPaint. All rights reserved.
//

import UIKit
import SpriteKit


class EditWindowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    var points:[(Float, Float, Float)] = []
    var plane:String = "XY"
    var updateRow:Int = 0

    
    @IBOutlet weak var pDV: pathDisplayView!
    @IBOutlet weak var horizantalAxisLabel: UILabel!
    @IBOutlet weak var verticalAxisLabel: UILabel!
    
    @IBOutlet weak var rightHorizantalAxisLabel: UILabel!
    @IBOutlet weak var midHorizantalAxisLabel: UILabel!
    @IBOutlet weak var leftHorizantalAxisLabel: UILabel!
    
    @IBOutlet weak var topVerticalAxisLabel: UILabel!
    @IBOutlet weak var midVerticalAxisLabel: UILabel!
    @IBOutlet weak var bottomVerticalAxisLabel: UILabel!
    
    
    @IBOutlet weak var yzOutlet: UIButton!
    @IBOutlet weak var xzOutlet: UIButton!
    @IBOutlet weak var xyOutlet: UIButton!
    
    @IBOutlet weak var pathNameTextFeild: UITextField!

    
    //***************************************TextFields and Sliders**************************************

    
    @IBOutlet weak var xPointTextField: UITextField!
    @IBOutlet weak var xSlider: UISlider!
    @IBAction func xSliderChanged(_ sender: UISlider) {
        xPointTextField.text = "\(xSlider.value)"
    }
    @IBAction func xTexFieldChanged(_ sender: UITextField) {
        xSlider.value = Float(xPointTextField.text!)!
    }
    
    
    @IBOutlet weak var yPointTextField: UITextField!
    @IBOutlet weak var ySlider: UISlider!
    @IBAction func ySliderChanged(_ sender: UISlider) {
        yPointTextField.text = "\(ySlider.value)"
    }
    @IBAction func yTexFieldChanged(_ sender: UITextField) {
        ySlider.value = Float(yPointTextField.text!)!
    }
    

    @IBOutlet weak var zPointTextField: UITextField!
    @IBOutlet weak var zSlider: UISlider!
    @IBAction func zSliderChanged(_ sender: UISlider) {
        zPointTextField.text = "\(zSlider.value)"
    }
    @IBAction func zTexFieldChanged(_ sender: UITextField) {
        zSlider.value = Float(zPointTextField.text!)!
    }
    
    @IBOutlet weak var pointTableView: UITableView!
    @IBOutlet weak var sucessOutlet: UILabel!
    

    @IBOutlet weak var updatePointButtonOutlet: UIButton!
    
    //********************************************Buttons***********************************************

    
    @IBAction func xzBarButtonTapped(_ sender: UIBarButtonItem) {
        plane = "XZ"
        pDV.plane = "XZ"
        pDV.setNeedsDisplay()
        verticalAxisLabel.text = "Z-Axis"
        horizantalAxisLabel.text = "X-Axis"
        midVerticalAxisLabel.isHidden = true
        bottomVerticalAxisLabel.text = "0"
        topVerticalAxisLabel.text = "400"
        
        
        xyOutlet.tintColor = xzOutlet.tintColor
        yzOutlet.tintColor = xzOutlet.tintColor
        xzOutlet.tintColor = UIColor.green

    }
    
    @IBAction func yzBarButtonTapped(_ sender: UIBarButtonItem) {
        plane = "YZ"
        pDV.plane = "YZ"
        pDV.setNeedsDisplay()
        verticalAxisLabel.text = "Z-Axis"
        horizantalAxisLabel.text = "Y-Axis"
        midVerticalAxisLabel.isHidden = true
        bottomVerticalAxisLabel.text = "0"
        topVerticalAxisLabel.text = "400"
        
        
        xzOutlet.tintColor = yzOutlet.tintColor
        xyOutlet.tintColor = yzOutlet.tintColor
        yzOutlet.tintColor = UIColor.green
    }
    
    @IBAction func xyBarButtonTapped(_ sender: UIBarButtonItem) {
        plane = "XY"
        pDV.plane = "XY"
        pDV.setNeedsDisplay()
        verticalAxisLabel.text = "Y-Axis"
        horizantalAxisLabel.text = "X-Axis"
        midVerticalAxisLabel.isHidden = false
        bottomVerticalAxisLabel.text = "-250"
        topVerticalAxisLabel.text = "250"
        
        
        xzOutlet.tintColor = xyOutlet.tintColor
        yzOutlet.tintColor = xyOutlet.tintColor
        xyOutlet.tintColor = UIColor.green
    }
    
    @IBAction func updatePointButtonTapped(_ sender: UIButton) {
        points[updateRow].0 = xSlider.value
        points[updateRow].1 = ySlider.value
        points[updateRow].2 = zSlider.value
        self.pointTableView.reloadData()
        pDV.points = self.points
        pDV.setNeedsDisplay()

        var indexPath:IndexPath = IndexPath(item: updateRow, section: 1)
        
        pointTableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addPointButtonTapped(_ sender: UIButton) {
        var newPoint:(Float, Float, Float)
        
        let xPoint = Float(xPointTextField.text!)
        let yPoint = Float(yPointTextField.text!)
        let zPoint = Float(zPointTextField.text!)
        
        if(xPoint != nil && yPoint != nil && zPoint != nil)
        {
            newPoint = (xPoint!, yPoint!, zPoint!)

            points.append(newPoint)
            
            pDV.points = self.points
            pDV.setNeedsDisplay()
            
            sucessOutlet.text = "Point Added: P(\(String(describing: xPoint!)), \(String(describing: yPoint!)), \(String(describing: zPoint!)))"
            
            //Reseting values
            xSlider.value = 0
            ySlider.value = 0
            zSlider.value = 0
            
            xPointTextField.text = "\(xSlider.value)"
            yPointTextField.text = "\(ySlider.value)"
            zPointTextField.text = "\(zSlider.value)"
            
            self.pointTableView.reloadData()
        }
        else
        {
            sucessOutlet.text = "Failed to Add Point"
        }
    }
    
    @IBAction func savePath(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        var newPath:[Float] = []
        
        if (pathNameTextFeild.text != nil && pathNameTextFeild.text != ""){
            if var pathNames = UserDefaults.standard.stringArray(forKey: "PathNames") as? [String]{
                let name:String = pathNameTextFeild.text!
                
                pathNames.append(pathNameTextFeild.text!)
                defaults.set(pathNames, forKey: "PathNames")
                for point in points
                {
                    newPath.append(contentsOf: [point.0, point.1, point.2])
                }
                
                defaults.set(newPath, forKey: name)
                
            }
            else
            {
                var pathNames:[String] = []
                let name:String = pathNameTextFeild.text!
                
                pathNames.append(pathNameTextFeild.text!)
                defaults.set(pathNames, forKey: "PathNames")
                for point in points
                {
                    newPath.append(contentsOf: [point.0, point.1, point.2])
                }                
                defaults.set(newPath, forKey: name)
            }
           
            
            
        }
        else{
            sucessOutlet.text = "Please enter a unique PathName"
        }
    }
    

    
   //*********************TableView Functions****************************
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            points.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            sucessOutlet.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return points.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointCellIdentifier", for: indexPath)
        
        let text:String = "P" + "(" + (String)(describing: points[indexPath.row].0) + "," + (String)(describing: points[indexPath.row].1) + "," + (String)(describing: points[indexPath.row].2) + ")"
        
        cell.textLabel?.text = text
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(points.count > indexPath.row)
        {
            xSlider.value = points[indexPath.row].0
            ySlider.value = points[indexPath.row].1
            zSlider.value = points[indexPath.row].2
            
            xPointTextField.text = "\(xSlider.value)"
            yPointTextField.text = "\(ySlider.value)"
            zPointTextField.text = "\(zSlider.value)"
            
            updatePointButtonOutlet.isEnabled = true
            updateRow = indexPath.row
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updatePointButtonOutlet.isEnabled = false
    }
    

    
    
    
    //******************************************Gesture Recognition*******************************************
    
    @objc func tapToPoint(_ sender:UITapGestureRecognizer)
    {
        let newPoint:CGPoint = sender.location(in: self.pDV)
        
        
        if(plane == "XY")
        {
            xSlider.value = Float(newPoint.x - 250)
            ySlider.value = Float(newPoint.y * -1 + 500 - 250)
            xPointTextField.text = "\(xSlider.value)"
            yPointTextField.text = "\(ySlider.value)"
            
            if(points.count > 0)
            {
                zSlider.value = points[points.count-1].2//getting the previous points z value
                zPointTextField.text = "\(zSlider.value)"
            }
            else
            {
                zSlider.value = 0
                zPointTextField.text = "\(0)"
            }
        }
        else if(plane == "XZ")
        {
            xSlider.value = Float(newPoint.x - 250)
            zSlider.value = Float(newPoint.y * -1 + 400)
            xPointTextField.text = "\(xSlider.value)"
            zPointTextField.text = "\(zSlider.value)"
            if(points.count > 0)
            {
                ySlider.value = points[points.count-1].1 //getting the previous points y value
                yPointTextField.text = "\(ySlider.value)"
            }
            else
            {
                ySlider.value = 0
                yPointTextField.text = "\(0)"
            }
        }
        else if(plane == "YZ")
        {
            ySlider.value = Float(newPoint.x - 250)
            zSlider.value = Float(newPoint.y * -1 + 400)
            yPointTextField.text = "\(ySlider.value)"
            zPointTextField.text = "\(zSlider.value)"
            if(points.count > 0)
            {
                xSlider.value = points[points.count-1].0//getting the previous points x value
                xPointTextField.text = "\(xSlider.value)"
            }
            else
            {
                xSlider.value = 0
                xPointTextField.text = "\(0)"
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pointTableView.dataSource = self
        pointTableView.delegate = self
        sucessOutlet.text = ""
        
        xSlider.maximumValue = 250
        ySlider.maximumValue = 250
        zSlider.maximumValue = 400
        
        xSlider.minimumValue = -250
        ySlider.minimumValue = -250
        zSlider.minimumValue = 0
        
        
        xSlider.value = 0
        ySlider.value = 0
        zSlider.value = 0
        
        
        xPointTextField.text = "\(xSlider.value)"
        yPointTextField.text = "\(ySlider.value)"
        zPointTextField.text = "\(zSlider.value)"

        
        xzOutlet.tintColor = xyOutlet.tintColor
        yzOutlet.tintColor = xyOutlet.tintColor
        xyOutlet.tintColor = UIColor.green
        
        var addPointGesture = UITapGestureRecognizer(target: self, action: #selector (EditWindowViewController.tapToPoint(_:)))
        pDV.addGestureRecognizer(addPointGesture)
        
        updatePointButtonOutlet.isEnabled = false
        
        verticalAxisLabel.text = "Y-Axis"
        horizantalAxisLabel.text = "X-Axis"
 
        
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
