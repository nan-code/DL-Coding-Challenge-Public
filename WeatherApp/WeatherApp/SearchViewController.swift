//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by Matthew Nanney on 7/15/16.
//  Copyright © 2016 Matthew Nanney. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

protocol AddLocationDelegate: class {
    func addNewLocation(location: Location)
}


class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblSearch: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    
    weak var delegate: AddLocationDelegate?
    
    var searchList = Array<Location>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //background gradient
        let gradient:GradientLayer = GradientLayer()
        gradient.setNeedsDisplay()
        gradient.colors = [UIColor.blueColor().CGColor, UIColor.cyanColor().CGColor]
        gradient.center = CGPointMake(self.view.frame.width / 2, self.view.frame.height / 2)
        gradient.radius = self.view.frame.width + 100
        gradient.frame = self.view.frame
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        
        self.txtSearch.delegate = self
        
        self.tableView.backgroundColor = UIColor.clearColor()
        
    }

    ////////////////////////////
    //MARK:- TableView Functions
    ////////////////////////////
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath) as! SearchTableViewCell
        
        let location = self.searchList[indexPath.row]
        
        cell.lblCity.text = location.city
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = self.searchList[indexPath.row]
        if let delegate = self.delegate {
            delegate.addNewLocation(location)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    ////////////////////////
    //MARK:- Extra Functions
    ////////////////////////

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.utf16.count + string.utf16.count - range.length
        
        if (newLength > 3){
            search(self)
        }
        
        if (newLength == 0){
            self.searchList.removeAll()
            self.tableView.reloadData()
        }
        
        return true
    }

    
    @IBAction func search(sender: AnyObject){
        if let text = self.txtSearch.text{
            self.autoCompleteSearch(text, completion: { (responseJSON) in
                self.searchList.removeAll()
                self.searchList.appendContentsOf(self.getLocations(responseJSON))
                self.tableView.reloadData()
            })
        }
    }
    
    func getLocations(json: JSON) -> Array<Location> {
        var locations = Array<Location>()
        
        if let results = json["RESULTS"].array{
            for result in results {
                let location = Location()
                location.city = result["name"].stringValue
                location.country = result["c"].stringValue
                location.lat = result["lat"].stringValue
                location.lon = result["lon"].stringValue
                
                locations.append(location)
            }
        }
        
        return locations
    }

}

