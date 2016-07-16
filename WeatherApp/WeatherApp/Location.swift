//
//  Location.swift
//  WeatherApp
//
//  Created by Matthew Nanney on 7/15/16.
//  Copyright © 2016 Matthew Nanney. All rights reserved.
//

import Foundation
import RealmSwift

class Location: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    
    var type:String?
    var country:String?
    var country_iso3166:String?
    var country_name:String?
    var state:String?
    var city:String?
    var tz_short:String?
    var tz_long:String?
    var lat:String?
    var lon:String?
    var zip:String?
    var magic:String?
    var wmo:String?
    var l:String?
    var requesturl:String?
    var wuiurl:String?

}
