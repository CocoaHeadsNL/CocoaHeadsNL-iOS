//
//  CoreLocationController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 23/08/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import CoreLocation

class CoreLocationController : NSObject, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.distanceFilter  = 5000
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.requestAlwaysAuthorization()
    }
    
    //MARK: - CLLocationManagerDelegate methods
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("didChangeAuthorizationStatus")
        
        switch status {
        case .NotDetermined:
            println(".NotDetermined")
            break
            
        case .AuthorizedAlways:
            println(".Authorized")
            self.locationManager.startUpdatingLocation()
            break
            
        case .AuthorizedWhenInUse:
            println(".AuthorizedWhenInUse")
            break
            
        case .Denied:
            println(".Denied")
            break
            
        default:
            println("Unhandled authorization status")
            break
            
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let location = locations.last as! CLLocation
        
        println("didUpdateLocations:  \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        var userInfo = [ "location" : location]
        
        NSNotificationCenter.defaultCenter().postNotificationName("LOCATION_AVAILABLE", object: nil, userInfo: userInfo)
    }
}