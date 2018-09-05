//
//  MapViewController.swift
//  LocationTracker
//
//  Created by Miles on 01/09/2018.
//  Copyright © 2018 Miles. All rights reserved.
//

import UIKit
import MapKit

import SwifterSwift
import ISHPullUp

class MapViewController: UIViewController, ISHPullUpContentDelegate, TrackingFunctionsDelegate, MKMapViewDelegate {


    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackingSwitch: UISwitch!
    @IBOutlet weak var centerButton: UIButton!

    var trackingFunctions = TrackingFunctions.shared
    var currentRouteLine: MKPolyline?

    //Bools to control mapview
    var mapCentered: Bool = true
    var nextChangeFromUser: Bool = false
    var isFirstCoordinate: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up vc look and delegates

        self.title = "Location Tracker"
        self.navigationController?.navigationBar.prefersLargeTitles = true

        self.view.backgroundColor = UIColor(hexString: "1976d2")

        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hexString: "004ba0")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)

        trackingFunctions.delegate = self
        mapView.delegate = self

    }

    // Change status bar to white
    override func viewDidAppear(_ animated: Bool) {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // User turns tracking on and off
    @IBAction func trackingSwitchChanged(_ sender: Any) {
        let changedSwitch = sender as! UISwitch
        let trackingOn = changedSwitch.isOn

        // Start Tracking
        trackingFunctions.setTracking(trackingOn)

        // Show user location and line
        self.mapView.showsUserLocation = trackingOn

        if trackingOn {
            self.currentRouteLine = MKPolyline(coordinates: [])
            guard let currentRouteLine = currentRouteLine else { return }
            self.mapView.add(currentRouteLine)
        } else {
            let overlays = self.mapView.overlays
            self.mapView.removeOverlays(overlays)
            self.currentRouteLine = nil
            isFirstCoordinate = true
        }


    }

    // Check if map needs to be centered
    @IBAction func centerButtonAction(_ sender: Any) {
        mapCentered = true
    }

    // From tracking delegate, update the user line and center the map
    func currentLocation(_ currentLocation: CLLocation) {

        if mapCentered {
            centerMap(currentLocation)
        }

        guard let currentRouteLine = currentRouteLine else { return }

        // First Coordinate can sometimes be wrong, so don't show that
        if isFirstCoordinate == false {
            let oldLine = currentRouteLine
            var oldCoords = oldLine.coordinates
            oldCoords.append(currentLocation.coordinate)
            self.currentRouteLine = MKPolyline(coordinates: oldCoords)
            self.mapView.remove(oldLine)
            self.mapView.add(currentRouteLine)

        } else {
            isFirstCoordinate = false
        }

    }

    // Func to center the map on a location
    func centerMap(_ coordinate: CLLocation) {
        let center = CLLocationCoordinate2D(latitude: coordinate.coordinate.latitude, longitude: coordinate.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
        self.mapView.setRegion(region, animated: true)
    }

    // Show error to user
    func locationError(error: String) {
        let alert = UIAlertController(title: "Error in getting location", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // Func needed for pullup controller
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forContentViewController contentVC: UIViewController) {}


    // Mapview funcs
    // control line to draw for user route
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        guard let polyLine = overlay as? MKPolyline else { return MKOverlayRenderer() }

        let overlayPL = MKPolylineRenderer(polyline: polyLine)
        overlayPL.strokeColor = UIColor(hexString: "00b0ff")
        overlayPL.lineWidth = 5

        return overlayPL

    }

    // Detect if region change is by user drag or function call
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let view = mapView.subviews.first
        for recognizer in (view?.gestureRecognizers)! {
            if recognizer.state == .began || recognizer.state == .ended {
                self.nextChangeFromUser = true
            }
        }
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if nextChangeFromUser {
            nextChangeFromUser = false
            mapCentered = false
        }
    }

}
