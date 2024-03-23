//
//  Location.swift
//  Detecting
//
//  Created by Joel Huggett on 2024-01-27.
//

import Foundation
import CoreLocation

class LocationDataManager: NSObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
	
	var currentLocation: CLLocation? = nil
    
    override init() {
        super.init()
        locationManager.delegate = self
        
        print("Location Data Manager Inited")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Received location update")
        for location in locations {
            print("COOR: ", location.coordinate)
            print("ALT: ", location.altitude)
            print("V-Ac: ", location.verticalAccuracy)
            print("H-Ac: ", location.horizontalAccuracy)
					
					currentLocation = location
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            print("Good to go")
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.distanceFilter = 0.1
            manager.startUpdatingLocation()
        default:
            print("auth status: ", manager.authorizationStatus.rawValue)
        }
    }
}
