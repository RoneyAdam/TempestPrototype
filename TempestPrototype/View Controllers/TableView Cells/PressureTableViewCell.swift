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
		let measurements = [Measurement(value: values.barometric_pressure, unit: UnitPressure.hectopascals), Measurement(value: values.station_pressure, unit: UnitPressure.hectopascals), Measurement(value: values.sea_level_pressure, unit: UnitPressure.hectopascals)]
		var convertedMeasurements = [String]()
		
		for item in measurements {
			var measurement = item
			if isImperial {
				measurement.convert(to: .inchesOfMercury)
			}
			let numberFormatter = NumberFormatter()
			numberFormatter.maximumFractionDigits = 2
			if var value = numberFormatter.string(from: NSNumber(value: measurement.value)) {
				value += isImperial ? " inHg" : " hPA"
				convertedMeasurements.append(value)
			}
		}
		//Baro and Station seem to always be the same, but I'll show them anyways 
		if convertedMeasurements.count == 3 {
			baroLabel.text = "Barometric: \(convertedMeasurements[0])"
			stationLabel.text = "Station: \(convertedMeasurements[1])"
			seaLabel.text = "Sea-level: \(convertedMeasurements[2])"
		}
	}
	
}
