//
//  ContainerViewController.swift
//  LocationTracker
//
//  Created by Miles on 02/09/2018.
//  Copyright © 2018 Miles. All rights reserved.
//

import UIKit

import ISHPullUp

class ContainerViewController: ISHPullUpViewController {

    // Container controller for the pullUp viewcontroller

    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contentVC = storyboard.instantiateViewController(withIdentifier: "mapVC") as! MapViewController
        let bottomVC = storyboard.instantiateViewController(withIdentifier: "savedDataVC") as! SavedDataViewController


        self.contentViewController = contentVC
        self.bottomViewController = bottomVC

        contentDelegate = contentVC
        sizingDelegate = bottomVC
        stateDelegate = bottomVC
        bottomVC.pullUpController = self

    }

}
