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

class MapViewController: UIViewController, ISHPullUpContentDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackingSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Location Tracker"
        self.navigationController?.navigationBar.prefersLargeTitles = true

    }

    @IBAction func trackingSwitchChanged(_ sender: Any) {
        let changedSwitch = sender as! UISwitch

        TrackingFunctions.shared.setTracking(changedSwitch.isOn)
    }


    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forContentViewController contentVC: UIViewController) {

    }

}
