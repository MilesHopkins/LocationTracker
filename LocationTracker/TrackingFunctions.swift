//
//  TrackingFunctions.swift
//  LocationTracker
//
//  Created by Miles on 01/09/2018.
//  Copyright © 2018 Miles. All rights reserved.
//

import Foundation
import CoreLocation

protocol TrackingFunctionsDelegate {
    func currentLocation(_ currentLocation: CLLocation)
    func locationError(error: String)
}

public class TrackingFunctions: NSObject, CLLocationManagerDelegate {

    static let shared = TrackingFunctions()

    var locationManager: CLLocationManager = CLLocationManager()

    var delegate: TrackingFunctionsDelegate?

    var lastLocation: CLLocation?

    var locationList: [CLLocation]?

    override init() {
        super.init()


    }


    public func setTracking(_ trackingStatus: Bool) {
        if trackingStatus {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self

            locationManager.startUpdatingLocation()
        }

        if !trackingStatus {

            locationManager.stopUpdatingLocation()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let delegate = delegate else { return }

        lastLocation = location
        locationList = locations

        delegate.currentLocation(location)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let delegate = delegate else { return }
        delegate.locationError(error: error.localizedDescription)
    }


}
