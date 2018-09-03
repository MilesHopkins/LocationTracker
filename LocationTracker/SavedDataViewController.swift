//
//  SavedDataTableViewController.swift
//  LocationTracker
//
//  Created by Miles on 01/09/2018.
//  Copyright © 2018 Miles. All rights reserved.
//

import UIKit

import ISHPullUp

class SavedDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ISHPullUpSizingDelegate, ISHPullUpStateDelegate {

    @IBOutlet weak var handle: ISHPullUpHandleView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!

    public var pullUpController: ISHPullUpViewController!

    var maxPullUpHeight: CGFloat = UIScreen.main.bounds.height - 40
    var minPullUpHeight: CGFloat = 95

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBar.prefersLargeTitles = true
        self.navBar.topItem?.title = "Saved Journeys"

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        navBar.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {

    }

    @objc func handleTapGesture(gesture: UITapGestureRecognizer) {
        pullUpController.toggleState(animated: true)
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, minimumHeightForBottomViewController bottomVC: UIViewController) -> CGFloat {
        return minPullUpHeight
    }

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, maximumHeightForBottomViewController bottomVC: UIViewController, maximumAvailableHeight: CGFloat) -> CGFloat {
        return maxPullUpHeight
    }

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, targetHeightForBottomViewController bottomVC: UIViewController, fromCurrentHeight height: CGFloat) -> CGFloat {

        if height > maxPullUpHeight * 0.4 {
            return maxPullUpHeight
        }
        return minPullUpHeight
    }

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forBottomViewController contentVC: UIViewController) {

    }

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, didChangeTo state: ISHPullUpState) {
        handle.setState(ISHPullUpHandleView.handleState(for: state), animated: true)
    }

}
