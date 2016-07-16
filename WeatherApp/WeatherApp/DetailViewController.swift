//
//  DetailViewController.swift
//  WeatherApp
//
//  Created by Matthew Nanney on 7/15/16.
//  Copyright © 2016 Matthew Nanney. All rights reserved.
//

import UIKit
import Haneke
import SwiftyJSON

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var viewCurrentTemp: UIView!
    @IBOutlet weak var viewForecast: UIView!
    @IBOutlet weak var viewForecastType: UIView!

    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblFeelsLikeTemp: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    
    @IBOutlet weak var imgViewCondition: UIImageView!
    
    @IBOutlet weak var collectionViewForecast: UICollectionView!
    @IBOutlet weak var segControlForecastType: UISegmentedControl!
    @IBOutlet weak var tableViewOverlay: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    
    var forecastDayList = Array<DayForecast>()
    var currentLocation:Location?

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        
        if let location = self.currentLocation {
            self.title = location.city
        }
        else{
            self.title = "Current Weather"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        //background gradient
        let gradient:GradientLayer = GradientLayer()
        gradient.setNeedsDisplay()
        gradient.colors = [UIColor.blueColor().CGColor, UIColor.cyanColor().CGColor]
        gradient.center = CGPointMake(self.view.frame.width / 2, self.view.frame.height / 2)
        gradient.radius = self.view.frame.width + 100
        gradient.frame = self.view.frame
        self.view.layer.insertSublayer(gradient, atIndex: 0)

        self.segControlForecastType.addTarget(self, action: #selector(DetailViewController.forecastSelected(_:)), forControlEvents: .ValueChanged)
        self.segControlForecastType.tintColor = UIColor.blueColor()
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Weather Data")
        self.refreshControl.addTarget(self, action: #selector(DetailViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableViewOverlay.addSubview(refreshControl)
        
        self.collectionViewForecast.backgroundColor = UIColor.clearColor()
        
    }
    
    
    ////////////////////////////
    //MARK:- TableView Functions
    ////////////////////////////
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        return cell
    }
    
    
    /////////////////////////////////
    //MARK:- CollectionView Functions
    /////////////////////////////////
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.getForecastDayCount()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var dayCount = self.getForecastDayCount()
        if (dayCount > 5){
            dayCount = 5
        }
        let width = collectionView.frame.width / CGFloat(dayCount)
        let height = collectionView.frame.height
        return CGSizeMake(width, height)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ForecastCell", forIndexPath: indexPath) as! ForecastCollectionViewCell
        
        cell.lblTemperature.text = "75 °F / 31 °C"
        cell.lblTemperature.textAlignment = .Center
        cell.lblDayOfWeek.text = "Monday"
        cell.lblDayOfWeek.textAlignment = .Center
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.layer.borderWidth = 0.5
        
        
        return cell
        
    }
    
    ////////////////////////
    //MARK:- Extra Functions
    ////////////////////////
    
    func refresh(sender:AnyObject) {
        // Make API for up to date current weather.
        
        if let currentLocation = self.currentLocation {
            self.currentWeatherData(currentLocation) { (resultJSON) in
                
                let currentObv = resultJSON["current_observation"]
                if let tempF = Double(currentObv["temp_f"].stringValue),
                    tempC = Double(currentObv["temp_c"].stringValue) {
                    let temperatureF = String(format:"%.1f", tempF)
                    let temperatureC = String(format:"%.1f", tempC)
                    self.lblTemperature.text = temperatureF + "°F (" + temperatureC + "°C)"
                }
                if let tempF = Double(currentObv["feelslike_f"].stringValue),
                    tempC = Double(currentObv["feelslike_c"].stringValue) {
                    let temperatureF = String(format:"%.1f", tempF)
                    let temperatureC = String(format:"%.1f", tempC)
                    self.lblFeelsLikeTemp.text = "Feels Like: " + temperatureF + "°F (" + temperatureC + "°C)"

                }
                if let icon = currentObv["icon_url"].string {
                    let url = NSURL(string: icon)!
                    self.imgViewCondition.hnk_setImageFromURL(url)
                }
                
                let location = currentObv["display_location"]
                self.lblCity.text = location["full"].stringValue
            }
        }
        
        refreshControl.endRefreshing()
    }
    
    func forecastSelected(sender: AnyObject){
        //do API call here to get new forecast data and then reload collection view
        
        self.collectionViewForecast.reloadData()
    }
    
    func getForecastDayCount() -> Int{
        var dayCount = 3
        let selectedIndex = self.segControlForecastType.selectedSegmentIndex
        switch (selectedIndex){
        case 0:
            dayCount = 3
            break
        case 1:
            dayCount = 7
            break
        case 2:
            dayCount = 10
            break
        default:
            dayCount = 3
            break
        }
        
        return dayCount
    }
    
    ////////////////////////
    //MARK:- Apple Functions
    ////////////////////////

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh(self)
        
        //here reload on view
    }
}

