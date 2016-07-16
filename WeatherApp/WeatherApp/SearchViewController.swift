//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by Matthew Nanney on 7/15/16.
//  Copyright © 2016 Matthew Nanney. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
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
        
        return cell
    }

}
