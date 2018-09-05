//
//  ViewJourneyTableViewController.swift
//  LocationTracker
//
//  Created by Miles on 05/09/2018.
//  Copyright © 2018 Miles. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SwifterSwift
import Realm
import RealmSwift

class ViewJourneyTableViewController: UITableViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!

    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var distance: UILabel!

    @IBOutlet weak var maxSpeed: UILabel!
    @IBOutlet weak var avSpeed: UILabel!
    @IBOutlet weak var heightChange: UILabel!

    var journey: RealmJourney!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        self.title = "View Journey"

    }

    override func viewWillAppear(_ animated: Bool) {
        setup()
    }


    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func setup() {

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        startTime.text = formatter.string(from: journey.startTime)
        endTime.text = formatter.string(from: journey.endTime)

        let timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute, .second]
        timeFormatter.unitsStyle = .abbreviated

        duration.text = timeFormatter.string(from: journey.startTime, to: journey.endTime)
        distance.text = String(format: "%.2f km", journey.totalDistance)


        maxSpeed.text = String(format: "%00.02f km/h", journey.maxSpeed)
        avSpeed.text = String(format: "%00.02f km/h", journey.averageSpeed)

        if journey.heightChange == -1 {
            heightChange.text = "n/a"
            heightChange.textColor = UIColor.lightGray
        } else {
            heightChange.text = String(format: "%01.0f m", journey.duration.mins)
        }

        let locations = journey.locations.map({ $0.location })
        let coordinates = Array(locations.map({ $0.coordinate }))
        let allLats = coordinates.map({ $0.latitude })
        let allLongs = coordinates.map({ $0.longitude })

        guard let latsMin = allLats.min(),
            let latsMax = allLats.max(),
            let longsMin = allLongs.min(),
            let longsMax = allLongs.max() else { return }

        let midLat = (latsMin + latsMax) / 2.0
        let midLong = (longsMin + longsMax) / 2.0

        let center = CLLocationCoordinate2D(latitude: midLat, longitude: midLong)
        let region = MKCoordinateRegion(center: center,
                                        span: MKCoordinateSpan(latitudeDelta: abs(latsMax - latsMin) + 0.005,
                                                               longitudeDelta: abs(longsMax - longsMin) + 0.005))
        self.mapView.setRegion(region, animated: true)
        self.mapView.isScrollEnabled = false
        self.mapView.isZoomEnabled = false
        self.mapView.isUserInteractionEnabled = false

        let routeLine = MKPolyline(coordinates: coordinates)

        let start = MKPointAnnotation()
        start.title = "Start"
        start.coordinate = coordinates.first!

        let end = MKPointAnnotation()
        end.title = "End"
        end.coordinate = coordinates.last!

        mapView.addAnnotations([start, end])


        self.mapView.add(routeLine)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        guard let polyLine = overlay as? MKPolyline else { return MKOverlayRenderer() }

        let overlayPL = MKPolylineRenderer(polyline: polyLine)
        overlayPL.strokeColor = UIColor.red
        overlayPL.lineWidth = 2

        return overlayPL

    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let annotationView = MKAnnotationView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        annotationView.roundCorners(.allCorners, radius: 5)

        if annotation.title == "Start" {
            annotationView.backgroundColor = UIColor(hexString: "2e7d32")
        } else {
            annotationView.backgroundColor = UIColor(hexString: "b71c1c")
        }

        return annotationView
    }
   

}
