//
//  CurrentLocation.swift
//  MyWeatherApp
//
//  Created by Sanjay Patil on 12/28/19.
//  Copyright © 2019 Sanjay Patil. All rights reserved.
//

import Foundation
class CurrentLocation {
    static let sharedInstance = CurrentLocation()
    fileprivate var _latitude:Double!
    fileprivate var _longitude:Double!
    var latitude:Double {
        get {
            return _latitude
        } set {
            _latitude = newValue
        }
    }
    
    var longitude:Double {
        get {
            return _longitude
        } set {
            _longitude = newValue
        }
    }
}


