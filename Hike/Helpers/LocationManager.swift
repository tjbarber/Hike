//
//  LocationManager.swift
//  Hike
//
//  Created by TJ Barber on 8/28/17.
//  Copyright © 2017 Novel. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    let manager = CLLocationManager()
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        
        self.authorizationStatus = CLLocationManager.authorizationStatus()
        if self.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
}

