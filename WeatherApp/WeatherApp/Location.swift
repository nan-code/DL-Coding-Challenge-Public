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
    
    
    dynamic var type:String = ""
    dynamic var country:String = ""
    dynamic var country_iso3166:String = ""
    dynamic var country_name:String = ""
    dynamic var state:String = ""
    dynamic var city:String = ""
    dynamic var tz_short:String = ""
    dynamic var tz_long:String = ""
    dynamic var lat:String = ""
    dynamic var lon:String = ""
    dynamic var zip:String = ""
    dynamic var magic:String = ""
    dynamic var wmo:String = ""
    dynamic var l:String = ""
    dynamic var requesturl:String = ""
    dynamic var wuiurl:String = ""
    
}
