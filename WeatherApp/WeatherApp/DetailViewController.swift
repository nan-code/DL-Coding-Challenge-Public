//
//  DetailViewController.swift
//  WeatherApp
//
//  Created by Matthew Nanney on 7/15/16.
//  Copyright © 2016 Matthew Nanney. All rights reserved.
//

import UIKit

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


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
//            if let label = self.detailDescriptionLabel {
//                label.text = detail.description
//            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        //background gradient
        let gradient:GradientLayer = GradientLayer()
        gradient.colors = [UIColor.blueColor().CGColor, UIColor.cyanColor().CGColor, UIColor.blueColor().CGColor]
        gradient.frame = self.view.bounds
        self.view.layer.addSublayer(gradient)

        self.segControlForecastType.addTarget(self, action: #selector(DetailViewController.forecastSelected(_:)), forControlEvents: .ValueChanged)
        self.segControlForecastType.tintColor = UIColor.blueColor()
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Weather Data")
        self.refreshControl.addTarget(self, action: #selector(DetailViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableViewOverlay.addSubview(refreshControl)
        
        self.collectionViewForecast.backgroundColor = UIColor.clearColor()
        self.viewForecast.layer.borderWidth = 1
        self.viewForecast.layer.borderColor = UIColor.blackColor().CGColor
        
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
        
        
        
        return cell
        
    }
    
    ////////////////////////
    //MARK:- Extra Functions
    ////////////////////////
    
    func refresh(sender:AnyObject) {
        // Make API for up to date current weather.
        
        
        
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
        
        //here reload on view
    }
}

