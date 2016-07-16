//
//  User.swift
//  WeatherApp
//
//  Created by Matthew Nanney on 7/15/16.
//  Copyright © 2016 Matthew Nanney. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    var userId:String = ""
    var userName:String = ""
    var lastLoginDt:String = ""
    var firstName:String = ""
    var lastName:String = ""

}
