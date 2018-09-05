//
//  SavedJourneyTableViewCell.swift
//  LocationTracker
//
//  Created by Miles on 04/09/2018.
//  Copyright © 2018 Miles. All rights reserved.
//

import UIKit

class SavedJourneyTableViewCell: UITableViewCell {

    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(with journey: RealmJourney) {

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        self.cellTitle.text = formatter.string(from: journey.startTime)

        self.distanceLabel.text = String(format: "%.2f km", journey.totalDistance)

        let timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute, .second]
        timeFormatter.unitsStyle = .abbreviated

        self.durationLabel.text = timeFormatter.string(from: journey.startTime, to: journey.endTime)



        if journey.maxSpeed == -1 {
            self.maxSpeedLabel.text = "n/a"
            self.maxSpeedLabel.textColor = UIColor.lightGray
        } else {
            self.maxSpeedLabel.text = String(format: "%00.02f km/h", journey.maxSpeed)
            self.maxSpeedLabel.textColor = UIColor.black
        }

    }

}
