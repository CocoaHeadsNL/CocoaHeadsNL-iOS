//
//  CoreLocationController.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 23/08/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation
import CoreLocation

class CoreLocationController: NSObject, CLLocationManagerDelegate {

    let locationManager: CLLocationManager = CLLocationManager()
    let locationNotification = "LOCATION_AVAILABLE"

    override init() {
        super.init()

        self.locationManager.delegate = self
        self.locationManager.distanceFilter  = 5000
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.requestWhenInUseAuthorization()
    }

    //MARK: - CLLocationManagerDelegate methods

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus")

        switch status {
        case .NotDetermined:
            print(".NotDetermined")
            break

        case .AuthorizedAlways:
            print(".Authorized")
            break

        case .AuthorizedWhenInUse:
            print(".AuthorizedWhenInUse")
            self.locationManager.startUpdatingLocation()
            break

        case .Denied:
            print(".Denied")
            break

        default:
            print("Unhandled authorization status")
            break

        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations.last!

        print("didUpdateLocations:  \(location.coordinate.latitude), \(location.coordinate.longitude)")

        let userInfo = [ "location" : location]

        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(locationNotification, object: nil, userInfo: userInfo)
    }
}
