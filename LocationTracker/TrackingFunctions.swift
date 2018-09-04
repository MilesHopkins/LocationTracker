//
//  TrackingFunctions.swift
//  LocationTracker
//
//  Created by Miles on 01/09/2018.
//  Copyright © 2018 Miles. All rights reserved.
//

import Foundation
import CoreLocation

import RealmSwift
import Realm

protocol TrackingFunctionsDelegate {
    func currentLocation(_ currentLocation: CLLocation)
    func locationError(error: String)
}

public class TrackingFunctions: NSObject, CLLocationManagerDelegate {

    static let shared = TrackingFunctions()

    var locationManager: CLLocationManager = CLLocationManager()

    let realm = try! Realm()

    var delegate: TrackingFunctionsDelegate?

    var lastLocation: CLLocation?

    var locationList: [CLLocation] = []

    public func setTracking(_ trackingStatus: Bool) {
        if trackingStatus {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.requestAlwaysAuthorization()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.delegate = self


            locationManager.startUpdatingLocation()
        }

        if !trackingStatus {

            locationManager.stopUpdatingLocation()
            saveJounrney()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let delegate = delegate else { return }

        lastLocation = location
        locationList.append(location)

        delegate.currentLocation(location)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let delegate = delegate else { return }
        delegate.locationError(error: error.localizedDescription)
    }

    func saveJounrney() {

        let newRealmJourney = RealmJourney()

        for location in locationList {
            let newRealmLocation = RealmLocation()
            newRealmLocation.latitude = location.coordinate.latitude
            newRealmLocation.longitude = location.coordinate.longitude
            newRealmLocation.altitude = location.altitude
            newRealmLocation.horzAcc = location.horizontalAccuracy
            newRealmLocation.vertAcc = location.verticalAccuracy
            newRealmLocation.course = location.course
            newRealmLocation.speed = location.speed
            newRealmLocation.timestamp = location.timestamp

            newRealmJourney.locations.append(newRealmLocation)
        }

        try! realm.write {
            realm.add(newRealmJourney)
        }

        self.locationList.removeAll()

    }

    func retrieveJourneys() -> Results<RealmJourney> {

        let results = realm.objects(RealmJourney.self)
        return results
    }
}
