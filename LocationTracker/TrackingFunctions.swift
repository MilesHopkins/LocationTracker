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

// protocol to pass coordinates and errors to the delegate
protocol TrackingFunctionsDelegate {
    func currentLocation(_ currentLocation: CLLocation)
    func locationError(error: String)
}

public class TrackingFunctions: NSObject, CLLocationManagerDelegate {
    // Shared instance for access
    static let shared = TrackingFunctions()

    //Location manager and delegate
    var locationManager: CLLocationManager = CLLocationManager()
    var delegate: TrackingFunctionsDelegate?
    var lastLocation: CLLocation?
    var locationList: [CLLocation] = []

    //Realm for saving
    let realm = try! Realm()

    //Called when user changes switch
    public func setTracking(_ trackingStatus: Bool) {
        if trackingStatus {
            //Setup location manager and ask for location access
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.requestAlwaysAuthorization()
            // Allow background collection
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.delegate = self

            print(locationList.count)

            locationManager.startUpdatingLocation()
        }

        if !trackingStatus {

            // On stop, stop updating the location and save the current list of coords
            locationManager.stopUpdatingLocation()
            saveJourney()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let delegate = delegate else { return }

        //if the last location is the same as the current location, don't add it to the list or return it
        if let lastLocation = lastLocation {
            if (lastLocation.coordinate.latitude == location.coordinate.latitude &&
                lastLocation.coordinate.longitude == location.coordinate.longitude) ||
                lastLocation.timestamp == location.timestamp{
                return
            }
        }

        // Otherwise save the last location and append to the list, then notify the delegate
        lastLocation = location
        locationList.append(location)

        delegate.currentLocation(location)
    }

    //On error, pass the description to the delegate
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let delegate = delegate else { return }
        delegate.locationError(error: error.localizedDescription)
    }

    // Save Journey on tracking off
    func saveJourney() {

        if locationList.count > 1 {

            // create a realm object, and for each location, add to it
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

            // add object to realm
            try! realm.write {
                realm.add(newRealmJourney)
            }
        }

        // clear the location list for the next journey
        self.locationList = []



    }

    // get all journeys from realm
    func retrieveJourneys() -> Results<RealmJourney> {

        let results = realm.objects(RealmJourney.self)
        return results
    }
}
