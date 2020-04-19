//
//  PressureTableViewCell.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/17/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit

class PressureTableViewCell: UITableViewCell {
	@IBOutlet weak var baroLabel: UILabel!
	@IBOutlet weak var stationLabel: UILabel!
	@IBOutlet weak var seaLabel: UILabel!
	
	//Setup the pressure labels
	func setupLabels(_ isImperial: Bool, _ values: Obs) {
		let unitConverter = UnitConverter()
		baroLabel.text = "Barometric: \(unitConverter.getStringForPressureLabel(values.barometric_pressure))"
		stationLabel.text = "Station: \(unitConverter.getStringForPressureLabel(values.station_pressure))"
		seaLabel.text = "Sea-level: \(unitConverter.getStringForPressureLabel(values.sea_level_pressure))"
	}
}
