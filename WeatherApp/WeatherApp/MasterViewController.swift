//
//  MasterViewController.swift
//  WeatherApp
//
//  Created by Matthew Nanney on 7/15/16.
//  Copyright © 2016 Matthew Nanney. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import CoreLocation
import SwiftyJSON

class MasterViewController: UITableViewController, CLLocationManagerDelegate, AddLocationDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = [Location]()

    var currentLocation = Location()
    let locationManager = CLLocationManager()
    var loadingView = UIView()
    var indicator = UIActivityIndicatorView()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Locations"
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        if let navigationController = self.navigationController {
            navigationController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            navigationController.navigationBar.shadowImage = UIImage()
            navigationController.navigationBar.translucent = true
            navigationController.navigationBar.tintColor = UIColor.whiteColor()
            
            let titleDict: [String: AnyObject] = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            navigationController.navigationBar.titleTextAttributes = titleDict

        }
        
        self.tableView.contentInset = UIEdgeInsetsMake(44,0,0,0);
        
        //background gradient
        let gradient:GradientLayer = GradientLayer()
        gradient.setNeedsDisplay()
        gradient.colors = [UIColor.blueColor().CGColor, UIColor.cyanColor().CGColor]
        gradient.center = CGPointMake(self.view.frame.width / 2, self.view.frame.height / 2)
        gradient.radius = self.view.frame.width + 100
        gradient.frame = self.view.frame

        let gradientView = UIView()
        gradientView.layer.insertSublayer(gradient, atIndex: 0)

        self.tableView.backgroundView = gradientView

        
        //initialize loading view
        self.indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.indicator.center = self.view.center
        let backgroundView = UIVisualEffectView()
        backgroundView.effect = UIBlurEffect()
        
        self.loadingView.addSubview(backgroundView)
        self.loadingView.addSubview(self.indicator)
        
        self.view.addSubview(self.loadingView)
        
        
        handleCurrentLocation()
        
        self.objects.removeAll()
        
        let realm = try! Realm()
        let locations = realm.objects(Location.self)
        for location in locations {
            self.objects.append(location)
        }
        

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        
        self.showLoading()
        self.handleCurrentLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        if let storyboard = self.storyboard, let searchViewController = storyboard.instantiateViewControllerWithIdentifier("SearchViewController") as? SearchViewController {
            searchViewController.delegate = self
            self.navigationController?.presentViewController(searchViewController, animated: true, completion: nil)
        }
        
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                var object:Location
                if (indexPath.row == 0){
                    object = currentLocation
                }
                else{
                    object = objects[indexPath.row - 1]
                }
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.currentLocation = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        cell.backgroundColor = UIColor.clearColor()
        
        if (indexPath.row != 0){
            let index = indexPath.row - 1
            let object = objects[index]
            cell.textLabel!.text = object.city + ", " + object.state
        }
        else{
            cell.textLabel!.text = currentLocation.city + ", " + currentLocation.state
        }
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if (indexPath.row == 0){
            return false
        }
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let realm = try! Realm()
            try! realm.write{
                realm.delete(objects[indexPath.row - 1])
            }
            
            objects.removeAtIndex(indexPath.row - 1)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    
    // MARK: - Extra Functions 
    
    
    func handleCurrentLocation(){

        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location{
            let locValue:CLLocationCoordinate2D = location.coordinate
            print("locations = \(locValue.latitude) \(locValue.longitude)")
            locationManager.stopUpdatingLocation()
            
            self.geoLookup("\(locValue.latitude)", long: "\(locValue.longitude)", completion: { (responseJSON) in
                let geoLocation = responseJSON["location"]
                
                let newLocation = self.getNewLocation(geoLocation)
                self.currentLocation = newLocation
                
                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    self.tableView.reloadData()
                    self.hideLoading()
                }

            })
        }
        else{
            let newLocation = Location()
            newLocation.city = "Detroit"
            newLocation.state = "MI"
            newLocation.country = "US"
            newLocation.country_name = "USA"
            newLocation.lat = "42.34453201"
            newLocation.lon = "-83.05988312"
            newLocation.zip = "48201"
            newLocation.requesturl = "US/MI/Detroit.html"
            self.currentLocation = newLocation
            
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self.tableView.reloadData()
                self.hideLoading()
            }
        }
    }

    
    func showLoading(){
        self.indicator.startAnimating()
        self.loadingView.hidden = false
        self.view.bringSubviewToFront(self.loadingView)
    }
    
    func hideLoading(){
        self.loadingView.hidden = true
        self.view.sendSubviewToBack(self.loadingView)
        self.indicator.stopAnimating()
    }

    func addNewLocation(location: Location){
        self.geoLookup(location.lat, long: location.lon, completion: { (responseJSON) in
            let geoLocation = responseJSON["location"]
            
            let newLocation = self.getNewLocation(geoLocation)
            
            var duplicate = false
            let realm = try! Realm()
            let locations = realm.objects(Location.self)
            for location in locations {
                if (location.city == newLocation.city && location.state == newLocation.state && location.country_name == newLocation.country_name){
                    duplicate = true
                    break
                }
            }
            
            if (!duplicate){
                try! realm.write {
                    realm.add(newLocation)
                }
                
                self.objects.append(newLocation)
            }

            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self.tableView.reloadData()
                self.hideLoading()
            }
            
        })
    }
    
    func getNewLocation(locationJSON: SwiftyJSON.JSON) -> Location{
        let newLocation = Location()
        newLocation.city = locationJSON["city"].stringValue
        newLocation.state = locationJSON["state"].stringValue
        newLocation.country = locationJSON["country"].stringValue
        newLocation.country_name = locationJSON["country_name"].stringValue
        newLocation.lat = locationJSON["lat"].stringValue
        newLocation.lon = locationJSON["lon"].stringValue
        newLocation.zip = locationJSON["zip"].stringValue
        newLocation.requesturl = locationJSON["requestUrl"].stringValue
        
        return newLocation
    }
 

}

