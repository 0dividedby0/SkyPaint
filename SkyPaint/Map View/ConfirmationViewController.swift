//
//  ConfirmationViewController.swift
//  SkyPaint
//
//  Created by Jason Halcomb on 3/4/18.
//  Copyright © 2018 SkyPaint. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ConfirmationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    //MARK: - Variable Declarations
    var paths: [RawPathMO] = []
    var path: RawPathMO!
    var fetchResultController: NSFetchedResultsController<RawPathMO>!
    var previousViewIsFlight = true
    
    @IBOutlet weak var pathNamesTableView: UITableView!
    @IBOutlet weak var pathPreviewView: pathDisplayView!
    
    @IBAction func back(_ sender: Any) {
        if (previousViewIsFlight) {
            performSegue(withIdentifier: "pathToFlySegue", sender: nil)
        }
        else {
            performSegue(withIdentifier: "pathToCreateSegue", sender: nil)
        }
    }
    
    //MARK: - UIViewController Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pathNamesTableView.dataSource = self
        pathNamesTableView.delegate = self
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paths.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pathNameIdentifier", for: indexPath)
        
        cell.textLabel?.text = paths[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        path = paths[indexPath.row]
        var tmpPoint: (Float, Float, Float)
        
        pathPreviewView.points = []
        
        for i: Int in 0...(path.numPoints as! Int)-1 {
            tmpPoint.0 = (path.longitude as! [Float])[i]
            tmpPoint.1 = (path.latitude as! [Float])[i]
            tmpPoint.2 = (path.altitude as! [Float])[i]
            pathPreviewView.points.append(tmpPoint)
        }
        
        pathPreviewView.setNeedsDisplay()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, sourceView, completionHandler) in
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let pathToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(pathToDelete)
                
                appDelegate.saveContext()
            }
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // MARK: - CoreDataController Methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pathNamesTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                pathNamesTableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                pathNamesTableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                pathNamesTableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            pathNamesTableView.reloadData()
        }
        if let fetchedObjects = controller.fetchedObjects {
            paths = fetchedObjects as! [RawPathMO]
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pathNamesTableView.endUpdates()
    }
    
    // MARK: - Navigation
    @IBAction func confirmPath(_ sender: Any) {
        performSegue(withIdentifier: "pathToScaleSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pathToScaleSegue" {
            let destinationController = segue.destination as! MapController
            destinationController.path = self.path
        }
    }

}
