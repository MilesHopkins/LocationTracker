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

    var duration: Double {
        return endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970
    }

    var averageSpeed: Double {
        let speeds = locations.map({ $0.speed })
        return speeds.average()
    }

    var maxSpeed: Double {
        let speeds = locations.map({ $0.speed })
        guard let maxSpeed = speeds.max() else {
            return 0
        }
        return maxSpeed
    }
    
    var heightChange: Double {
        let altitudes = locations.map({ $0.altitude })
        guard let last = altitudes.last, let first = altitudes.first else {
            return 0
        }
        return last - first
    }

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
