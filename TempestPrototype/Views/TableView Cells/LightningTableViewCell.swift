//
//  LightningTableViewCell.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/16/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit

class LightningTableViewCell: UITableViewCell {
	@IBOutlet weak var strikeCount: UILabel!
	@IBOutlet weak var lastStrikeDistance: UILabel!
	@IBOutlet weak var timeSinceLabel: UILabel!
	
	func setupLabels(_ isImperial: Bool, _ values: Obs) {
		strikeCount.text = "Strike Count: \(values.lightning_strike_count_last_3hr) -- in the last 3 hours"
		
		//Get time since last strike (epoch)
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .abbreviated
		formatter.allowedUnits = [.month, .day, .hour, .minute]
		formatter.maximumUnitCount = 2

		if let value = formatter.string(from: values.lightning_strike_last_epoch , to: Date()) {
			timeSinceLabel.text = "\(value) ago"
		}
		
		let unit = UnitConverter()
		lastStrikeDistance.text = "Last Strike Distance: \(unit.getStringForLargeLengthLabel(Double(values.lightning_strike_last_distance)))"
		
	}
	
}
