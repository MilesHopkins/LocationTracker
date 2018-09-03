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

class MapViewController: UIViewController, ISHPullUpContentDelegate, TrackingFunctionsDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {


    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackingSwitch: UISwitch!
    @IBOutlet weak var centerButton: UIButton!

    var trackingFunctions = TrackingFunctions()
    var currentRouteLine: MKPolyline?

    var mapCentered: Bool = true
    var nextChangeFromUser: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Location Tracker"
        self.navigationController?.navigationBar.prefersLargeTitles = true

        self.view.backgroundColor = UIColor(hexString: "1976d2")

        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hexString: "004ba0")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)

        let mapDraggedGest = UIPanGestureRecognizer(target: self, action: #selector(self.mapDragged(gestureRecognizer:)))
        mapDraggedGest.delegate = self
        //self.mapView.addGestureRecognizer(mapDraggedGest)

        trackingFunctions.delegate = self
        mapView.delegate = self

    }

    override func viewDidAppear(_ animated: Bool) {
        self.setNeedsStatusBarAppearanceUpdate()
    }

    @IBAction func trackingSwitchChanged(_ sender: Any) {
        let changedSwitch = sender as! UISwitch
        let trackingOn = changedSwitch.isOn

        trackingFunctions.setTracking(trackingOn)
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

    @IBAction func centerButtonAction(_ sender: Any) {
        mapCentered = true
    }

    @objc func mapDragged(gestureRecognizer: UIGestureRecognizer) {
        mapCentered = false
    }

    var isFirstCoordinate: Bool = true

    func currentLocation(_ currentLocation: CLLocation) {

        if mapCentered {
            centerMap(currentLocation)
        }

        guard let currentRouteLine = currentRouteLine else { return }

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

    func centerMap(_ coordinate: CLLocation) {
        let center = CLLocationCoordinate2D(latitude: coordinate.coordinate.latitude, longitude: coordinate.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
        self.mapView.setRegion(region, animated: true)
    }

    func locationError(error: String) {
        
    }

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forContentViewController contentVC: UIViewController) {}

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        guard let polyLine = overlay as? MKPolyline else { return MKOverlayRenderer() }

        let overlayPL = MKPolylineRenderer(polyline: polyLine)
        overlayPL.strokeColor = UIColor.red
        overlayPL.lineWidth = 5

        return overlayPL

    }

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
