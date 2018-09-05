//
//  RealmJourney.swift
//  LocationTracker
//
//  Created by Miles on 04/09/2018.
//  Copyright © 2018 Miles. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift
import Realm
import SwifterSwift

//Realm object to store the list of locations in Realm
//Computed variables are not stored in realm, so all variables other than locations are computed when needed

public class RealmJourney: Object {

    var locations: List<RealmLocation> = List<RealmLocation>()
    
    var startTime: Date {
        guard let first = locations.first?.timestamp else {
            return Date(timeIntervalSince1970: 0)
        }
        return first
    }

    var endTime: Date {
        guard let last = locations.last?.timestamp else {
            return Date(timeIntervalSince1970: 0)
        }
        return last
    }

    var duration: (hours: Double, mins: Double, secs: Double) {
        return (endTime.hoursSince(startTime), endTime.minutesSince(startTime), endTime.secondsSince(startTime))
    }


    var averageSpeed: Double {
        let speeds = locations.map({ $0.speed })

        // If not using gps, speed is always -1, so check that and then manually work out average
        if speeds.average() != -1 {
            return ((speeds.average() * 18.0) / 5.0)
        } else {
            var allSpeeds: [Double] = []
            for index in 0 ..< (locations.count - 1) {
                let loc1 = locations[index]
                let loc2 = locations[index + 1]

                let distanceBetween = loc1.location.distance(from: loc2.location)
                let timeBetween = loc2.timestamp.secondsSince(loc1.timestamp)

                let speedInMetersPerSecond = distanceBetween/timeBetween
                allSpeeds.append(speedInMetersPerSecond)
            }

            return  ((allSpeeds.average() * 18.0) / 5.0)

        }
    }

    var maxSpeed: Double {
        let speeds = locations.map({ $0.speed })
        guard let maxSpeed = speeds.max() else {
            return 0
        }

        // If not using gps, speed is always -1, so check that and then manually work out max
        if maxSpeed != -1 {
            return ((maxSpeed * 18.0) / 5.0)
        } else {
            var maxSpeed = 0.0
            for index in 0 ..< (locations.count - 1) {
                let loc1 = locations[index]
                let loc2 = locations[index + 1]

                let distanceBetween = loc1.location.distance(from: loc2.location)
                let timeBetween = loc2.timestamp.secondsSince(loc1.timestamp)

                let speedInMetersPerSecond = distanceBetween/timeBetween
                if speedInMetersPerSecond > maxSpeed {
                    maxSpeed = speedInMetersPerSecond
                }
            }

            return  ((maxSpeed * 18.0) / 5.0)

        }
    }
    
    var heightChange: Double {
        let altitudes = locations.map({ $0.altitude })
        guard let last = altitudes.last, let first = altitudes.first else {
            return 0
        }
        return last - first
    }

    // work out distance from point to point (not as crow flies)
    var totalDistance: Double {
        var distance: Double = 0
        for index in 0 ..< (locations.count - 1) {
            let loc1 = locations[index]
            let loc2 = locations[index + 1]
            let distanceBetween = loc1.location.distance(from: loc2.location)
            distance += (distanceBetween/1000)
        }

        return distance
    }

}

//Copy of CLLocation, as only basic objects can be stored in realm
public class RealmLocation: Object {
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var altitude: Double = 0
    @objc dynamic var horzAcc: Double = 0
    @objc dynamic var vertAcc: Double = 0
    @objc dynamic var course: Double = 0
    @objc dynamic var speed: Double = 0
    @objc dynamic var timestamp: Date = Date(timeIntervalSince1970: 0)
    
    var location: CLLocation {
        let createdLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude,
                                                                            longitude: longitude),
                                         altitude: altitude,
                                         horizontalAccuracy: horzAcc,
                                         verticalAccuracy: vertAcc,
                                         course: course,
                                         speed: speed,
                                         timestamp: timestamp)

        return createdLocation
    }
}
