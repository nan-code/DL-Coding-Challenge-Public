//
//  ViewControllerExtension.swift
//  WeatherApp
//
//  Created by Matthew Nanney on 7/15/16.
//  Copyright © 2016 Matthew Nanney. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

extension UIViewController {
    
    func currentWeatherData(location: Location, completion: (JSON) -> Void) {
        let city = location.city.stringByReplacingOccurrencesOfString(" ", withString: "_")
        let state = location.country_name == "USA" ? location.state : location.country_name

        Alamofire.request(
            .GET,
            "http://api.wunderground.com/api/36e92782e9780dae/conditions/q/\(state)/\(city).json"
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while fetching tags: \(response.result.error)")
                    completion(JSON(""))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: AnyObject] else {
                    print("Invalid tag information received from service")
                    completion(JSON(""))
                    return
                }
                                
                print(JSON(responseJSON))
                completion(JSON(responseJSON))
        }
    }
    
    func hourlyForecast(location: Location, completion: (JSON) -> Void) {
        let city = location.city.stringByReplacingOccurrencesOfString(" ", withString: "_")
        let state = location.country_name == "USA" ? location.state : location.country_name
        
        Alamofire.request(
            .GET,
            "http://api.wunderground.com/api/36e92782e9780dae/hourly/q/\(state)/\(city).json"
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while fetching tags: \(response.result.error)")
                    completion(JSON(""))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: AnyObject] else {
                    print("Invalid tag information received from service")
                    completion(JSON(""))
                    return
                }
                
                print(JSON(responseJSON))
                completion(JSON(responseJSON))
        }
    }
    
    func dailyForecast(location: Location, completion: (JSON) -> Void) {
        let city = location.city.stringByReplacingOccurrencesOfString(" ", withString: "_")
        let state = location.country_name == "USA" ? location.state : location.country_name
        
        Alamofire.request(
            .GET,
            "http://api.wunderground.com/api/36e92782e9780dae/forecast/q/\(state)/\(city).json"
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while fetching tags: \(response.result.error)")
                    completion(JSON(""))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: AnyObject] else {
                    print("Invalid tag information received from service")
                    completion(JSON(""))
                    return
                }
                
                print(JSON(responseJSON))
                completion(JSON(responseJSON))
        }
    }

    func tenDayForecast(location: Location, completion: (JSON) -> Void) {
        let city = location.city.stringByReplacingOccurrencesOfString(" ", withString: "_")
        let state = location.country_name == "USA" ? location.state : location.country_name
        
        Alamofire.request(
            .GET,
            "http://api.wunderground.com/api/36e92782e9780dae/forecast10day/q/\(state)/\(city).json"
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while fetching tags: \(response.result.error)")
                    completion(JSON(""))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: AnyObject] else {
                    print("Invalid tag information received from service")
                    completion(JSON(""))
                    return
                }
                
                print(JSON(responseJSON))
                completion(JSON(responseJSON))
        }
    }

    
    func geoLookup(lat: CLLocationDegrees, long: CLLocationDegrees, completion: (JSON) -> Void) {
        Alamofire.request(
            .GET,
            "http://api.wunderground.com/api/36e92782e9780dae/geolookup/q/\(lat),\(long).json"
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while fetching tags: \(response.result.error)")
                    completion(JSON(""))
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: AnyObject] else {
                    print("Invalid tag information received from service")
                    completion(JSON(""))
                    return
                }
                
                print(JSON(responseJSON))
                completion(JSON(responseJSON))
        }
    }

}