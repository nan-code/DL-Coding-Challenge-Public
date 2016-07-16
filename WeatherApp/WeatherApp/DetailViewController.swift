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
    var loadingView = UIView()
    var indicator = UIActivityIndicatorView()
    
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
        
        self.title = getCityLabel()
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

        //initialize loading view
        self.indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.indicator.center = self.view.center
        let backgroundView = UIVisualEffectView()
        backgroundView.effect = UIBlurEffect()
        
        self.loadingView.addSubview(backgroundView)
        self.loadingView.addSubview(self.indicator)
        
        self.view.addSubview(self.loadingView)

        
        self.segControlForecastType.addTarget(self, action: #selector(DetailViewController.forecastSelected(_:)), forControlEvents: .ValueChanged)
        self.segControlForecastType.tintColor = UIColor.whiteColor()
        
        
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
        return self.forecastDayList.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var dayCount = self.forecastDayList.count
        if (dayCount > 5){
            dayCount = 5
        }
        let width = collectionView.frame.width / CGFloat(dayCount)
        let height = collectionView.frame.height
        return CGSizeMake(width, height)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ForecastCell", forIndexPath: indexPath) as! ForecastCollectionViewCell
        
        let forecast = self.forecastDayList[indexPath.item]
        cell.lblTemperature.text =  "\(forecast.temperatureF)°F / \(forecast.temperatureC) °C"
        cell.lblTemperature.textAlignment = .Center
        cell.lblDayOfWeek.text = "\(forecast.dayOfWeek)"
        cell.lblDayOfWeek.textAlignment = .Center
        if let url = NSURL(string: forecast.conditionIconUrl){
            cell.imgViewCondition.hnk_setImageFromURL(url)
        }
        
        return cell
        
    }
    
    ////////////////////////
    //MARK:- Extra Functions
    ////////////////////////
    
    func refresh(sender:AnyObject) {
        // Make API for up to date current weather.
        
        if let currentLocation = self.currentLocation {
            self.currentWeatherData(currentLocation) { (responseJSON) in
                
                let forecast:DayForecast = self.getCurrentForecast(responseJSON)
                self.lblTemperature.text = forecast.temperatureF + "°F (" + forecast.temperatureC + "°C)"
                self.lblFeelsLikeTemp.text = "Feels Like: " + forecast.feelsLikeF + "°F (" + forecast.feelsLikeC + "°C)"
                if let url = NSURL(string: forecast.conditionIconUrl){
                    self.imgViewCondition.hnk_setImageFromURL(url)
                }

                self.forecastSelected(self)
                self.refreshControl.endRefreshing()
                self.hideLoading()
            }
            
            self.lblCity.text = getCityLabel()
            self.title = getCityLabel()
        }
        
    }
    
    func getCurrentForecast(result: SwiftyJSON.JSON) -> DayForecast {
        let forecast = DayForecast()
        
        let currentObv = result["current_observation"]
        if let tempF = Double(currentObv["temp_f"].stringValue),
            tempC = Double(currentObv["temp_c"].stringValue) {
            forecast.temperatureF = String(format:"%.1f", tempF)
            forecast.temperatureC = String(format:"%.1f", tempC)
        }
        if let tempF = Double(currentObv["feelslike_f"].stringValue),
            tempC = Double(currentObv["feelslike_c"].stringValue) {
            forecast.feelsLikeF = String(format:"%.1f", tempF)
            forecast.feelsLikeC = String(format:"%.1f", tempC)
        }
        forecast.conditionIconUrl = currentObv["icon_url"].stringValue
        
        return forecast
    }
    
    func getHourlyForecast(result: SwiftyJSON.JSON) -> Array<DayForecast> {
        var forecasts = Array<DayForecast>()

        if let hours = result["hourly_forecast"].array {
            for hour in hours {
                let forecast = DayForecast()
                
                forecast.dayOfWeek = hour["FCTTIME"]["civil"].stringValue
                
                if let tempF = Double(hour["temp"]["english"].stringValue),
                    tempC = Double(hour["temp"]["metric"].stringValue) {
                    forecast.temperatureF = String(format:"%.1f", tempF)
                    forecast.temperatureC = String(format:"%.1f", tempC)
                }
                if let tempF = Double(hour["feelslike"]["english"].stringValue),
                    tempC = Double(hour["feelslike"]["metric"].stringValue) {
                    forecast.feelsLikeF = String(format:"%.1f", tempF)
                    forecast.feelsLikeC = String(format:"%.1f", tempC)
                }
                forecast.conditionIconUrl = hour["icon_url"].stringValue
                
                forecasts.append(forecast)
            }
        }
        
        return forecasts
    }
    
    func getDayForecast(result: SwiftyJSON.JSON) -> Array<DayForecast> {
        var forecasts = Array<DayForecast>()
        
        if let days = result["forecast"]["simpleforecast"]["forecastday"].array {
            for day in days {
                let forecast = DayForecast()
                
                forecast.dayOfWeek = day["date"]["weekday"].stringValue

                if let tempF = Double(day["high"]["fahrenheit"].stringValue),
                    tempC = Double(day["low"]["celsius"].stringValue) {
                    forecast.temperatureF = String(format:"%.1f", tempF)
                    forecast.temperatureC = String(format:"%.1f", tempC)
                }
                if let tempF = Double(day["feelslike"]["fahrenheit"].stringValue),
                    tempC = Double(day["low"]["celsius"].stringValue) {
                    forecast.feelsLikeF = String(format:"%.1f", tempF)
                    forecast.feelsLikeC = String(format:"%.1f", tempC)
                }
                forecast.conditionIconUrl = day["icon_url"].stringValue
                
                forecasts.append(forecast)
            }
        }
        
        return forecasts
    }

    
    func forecastSelected(sender: AnyObject){
        //do API call here to get new forecast data and then reload collection view
        
        if let currentLocation = self.currentLocation {
            self.showLoading()
            let selectedIndex = self.segControlForecastType.selectedSegmentIndex
            if (selectedIndex == 1){ //3 day
                self.dailyForecast(currentLocation, completion: { (responseJSON) in
                    self.forecastDayList.removeAll()
                    self.forecastDayList.appendContentsOf(self.getDayForecast(responseJSON))
                    self.reloadForecasts()
                })
            }
            else if (selectedIndex == 2){ //10 day
                self.tenDayForecast(currentLocation, completion: { (responseJSON) in
                    self.forecastDayList.removeAll()
                    self.forecastDayList.appendContentsOf(self.getDayForecast(responseJSON))
                    self.reloadForecasts()
                })
            }
            else{ //hourly
                self.hourlyForecast(currentLocation, completion: { (responseJSON) in
                    self.forecastDayList.removeAll()
                    self.forecastDayList.appendContentsOf(self.getHourlyForecast(responseJSON))
                    self.reloadForecasts()
                })
            }
            
        }
    }
    
    func reloadForecasts(){
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self.collectionViewForecast.reloadData()
            self.hideLoading()
        }
    }
    
    func getCityLabel() -> String{
        var city = ""
        if let currentLocation = self.currentLocation{
            let state = currentLocation.country_name == "USA" ? currentLocation.state : currentLocation.country_name
            city = currentLocation.city + ", " + state
        }
        return city
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

    ////////////////////////
    //MARK:- Apple Functions
    ////////////////////////

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showLoading()
        self.refresh(self)
        
        //here reload on view
    }
}

