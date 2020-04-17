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
	
	func setupLabels(_ isImperial: Bool, _ distance: Int, _ time: Date, _ hoursCount: Int) {
		strikeCount.text = "Strike Count: \(hoursCount) -- in the last 3 hours"
		
		//Get time since last strike (epoch)
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.allowedUnits = [.month, .day, .hour, .minute]
		formatter.maximumUnitCount = 2

		if var value = formatter.string(from: time , to: Date()) {
			value = value.replacingOccurrences(of: "hours", with: "hrs")
			value = value.replacingOccurrences(of: "minutes", with: "mins")
			timeSinceLabel.text = "\(value) ago"
		}
		
		var measurement = Measurement(value: Double(distance), unit: UnitLength.kilometers)
		measurement = isImperial ? measurement.converted(to: .miles) : measurement
		print(time)
		let numberFormatter = NumberFormatter()
		numberFormatter.maximumFractionDigits = 0
		if var value = numberFormatter.string(from: NSNumber(value: measurement.value)) {
			value += isImperial ? " mi" : " km"
			lastStrikeDistance.text = "Last Strike Distance: \(value)"
		}
	}
	
}
